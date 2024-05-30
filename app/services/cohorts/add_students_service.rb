module Cohorts
  # Adds a list of new students to a cohort.
  class AddStudentsService
    def initialize(
      cohort,
      notify: false,
      notification_service: Developers::NotificationService.new
    )
      @cohort = cohort
      @notify = notify
      @team_name_translation = {}
      @notification_service = notification_service
    end

    # Accepts a list of students to add to a cohort. Ignores students who are already present.
    #
    # @param student_list [Array] list of students to be added. Each entry should contain email, name, and tags.
    # @return [Array] the number of students who were just added to the database, and the number that was supplied for addition.
    def add(student_list)
      new_students = sanitize_students(unpersisted_students(student_list))

      students =
        Cohort.transaction do
          students =
            new_students.map { |student_data| create_new_student(student_data) }

          notify_students(students)

          # Add the tags to the school's list of student tags. This is useful for retrieval in the school admin interface.
          new_student_tags =
            new_students.map { |student| student.tags || [] }.flatten.uniq
          school.student_tag_list << new_student_tags
          school.save!

          students
        end

      students.each do |student|
        @notification_service.execute(
          course,
          :student_added,
          student.user,
          @cohort
        )
      end

      students.map { |student| student.id }
    end

    private

    def notify_students(students)
      return unless @notify

      students.each do |student|
        StudentMailer.enrollment(student).deliver_later
      end
    end

    # Remove team name from students who aren't teamed up with anyone else.
    def sanitize_students(students)
      team_sizes = {}

      students.select do |student|
        if student.team_name.present?
          team_sizes[student.team_name] ||= 0
          team_sizes[student.team_name] += 1
        end
      end

      students.map do |student|
        if student.team_name.present?
          if team_sizes[student.team_name] > 1
            student
          else
            student_without_team_name(student)
          end
        else
          student
        end
      end
    end

    def student_without_team_name(student)
      OpenStruct.new(student.to_h.except(:team_name))
    end

    def create_new_student(student)
      # Create a user and generate a login token.
      user = school.users.with_email(student.email).first
      user = school.users.create!(email: student.email) if user.blank?

      # If a user was already present, don't override values of name, title or affiliation.
      user.update!(
        name: user.name.presence || student.name,
        title: user.title.presence || student.title.presence || "Student",
        affiliation: user.affiliation.presence || student.affiliation.presence
      )

      team = find_or_create_team(student)

      # Finally, create a student profile for the user.
      Student.create!(
        user: user,
        team: team,
        tag_list: student.tags,
        cohort: @cohort
      )
    end

    def unpersisted_students(students)
      requested_emails = students.map { |x| x.email.downcase }
      enrolled_student_emails =
        course
          .students
          .joins(:user)
          .where(users: { email: requested_emails })
          .pluck(:email)

      students.reject do |student|
        student.email.downcase.in?(enrolled_student_emails)
      end
    end

    def find_or_create_team(student)
      return if student.team_name.blank?

      team = @team_name_translation[student.team_name]

      return team if team.present?

      team = Team.create!(name: student.team_name, cohort: @cohort)

      @team_name_translation[team.name] = team
      team
    end

    def school
      @school ||= course.school
    end

    def course
      @course ||= @cohort.course
    end
  end
end
