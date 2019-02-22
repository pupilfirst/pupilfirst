module Courses
  class AddStudentsService
    def initialize(course)
      @course = course
    end

    def add(students_list)
      first_level = @course.levels.find_by(number: 1)

      Course.transaction do
        students_list.each do |student|
          user = User.with_email(student.email) || User.create!(email: student.email)
          user.regenerate_login_token if user.login_token.blank?

          startup = Startup.create!(
            name: student.name,
            product_name: student.name,
            level: first_level
          )

          Founder.create!(user: user, name: student.name, startup: startup)
        end
      end
    end
  end
end
