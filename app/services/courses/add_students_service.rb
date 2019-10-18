module Courses
  # Adds a list of new students to a course.
  class AddStudentsService
    def initialize(course)
      @course = course
    end

    # Accepts a list of students to add to a course. Ignores students who are already present.
    #
    # @param student_list [Array] list of students to be added. Each entry should contain email, name, and tags.
    # @return [Array] the number of students who were just added to the database, and the number that was supplied for addition.
    def add(student_list)
      new_students = unpersisted_students(student_list)

      Course.transaction do
        new_students.each do |student|
          create_new_student(student)
        end

        # Add the tags to the school's list of founder tags. This is useful for retrieval in the school admin interface.
        new_student_tags = new_students.map { |student| student.tags || [] }.flatten.uniq
        school.founder_tag_list << new_student_tags
        school.save!
      end

      [new_students.count, student_list.count]
    end

    private

    def create_new_student(student)
      # Create a user and generate a login token.
      user = User.where(email: student.email, school: school).first_or_create!

      user.regenerate_login_token if user.login_token.blank?

      # If a user was already present, don't override values of name, title or affiliation.
      user.update!(
        name: user.name.presence || student.name,
        title: user.title.presence || student.title.presence || "Student",
        affiliation: user.affiliation.presence || student.affiliation
      )

      startup = Startup.create!(name: student.name, level: first_level)

      # Finally, create a student profile for the user and tag it.
      founder = Founder.create!(user: user, startup: startup)
      founder.tag_list << student.tags
      founder.save!
    end

    def unpersisted_students(students)
      requested_emails = students.map(&:email)
      enrolled_student_emails = @course.founders.joins(:user).where(users: { email: requested_emails }).pluck(:email)

      students.reject do |student|
        student.email.in?(enrolled_student_emails)
      end
    end

    def school
      @school ||= @course.school
    end

    def first_level
      @first_level ||= @course.levels.find_by(number: 1)
    end
  end
end
