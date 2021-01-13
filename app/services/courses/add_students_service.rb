module Courses
  # Adds a list of new students to a course.
  class AddStudentsService
    def initialize(course, notify: false)
      @course = course
      @notify = notify
      @team_name_translation = {}
    end

    # Accepts a list of students to add to a course. Ignores students who are already present.
    #
    # @param student_list [Array] list of students to be added. Each entry should contain email, name, and tags.
    # @return [Array] the number of students who were just added to the database, and the number that was supplied for addition.
    def add(student_list)
      new_students = sanitize_students(unpersisted_students(student_list))

      Course.transaction do
        students = new_students.map do |student_data|
          create_new_student(student_data)
        end

        notify_students(students)

        # Add the tags to the school's list of founder tags. This is useful for retrieval in the school admin interface.
        new_student_tags = new_students.map { |student| student.tags || [] }.flatten.uniq
        school.founder_tag_list << new_student_tags
        school.save!

        students.map { |student| student.id }
      end
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

      user.regenerate_login_token if user.login_token.blank?

      # If a user was already present, don't override values of name, title or affiliation.
      user.update!(
        name: user.name.presence || student.name,
        title: user.title.presence || student.title.presence || "Student",
        affiliation: user.affiliation.presence || student.affiliation.presence
      )

      team = find_or_create_team(student)

      # Finally, create a student profile for the user.
      Founder.create!(user: user, startup: team)
    end

    def unpersisted_students(students)
      requested_emails = students.map(&:email)
      enrolled_student_emails = @course.founders.joins(:user).where(users: { email: requested_emails }).pluck(:email)

      students.reject do |student|
        student.email.in?(enrolled_student_emails)
      end
    end

    def find_or_create_team(student)
      team = @team_name_translation[student.team_name]

      return team if team.present?

      team = Startup.create!(
        name: student.team_name.presence || student.name,
        level_id: first_level.id,
        tag_list: student.tags
      )

      @team_name_translation[team.name] = team
      team
    end

    def school
      @school ||= @course.school
    end

    def first_level
      @first_level ||= @course.levels.find_by(number: 1)
    end
  end
end
