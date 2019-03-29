module Courses
  class AddStudentsService
    def initialize(course)
      @course = course
    end

    def add(students_list, tags)
      first_level = @course.levels.find_by(number: 1)

      Course.transaction do
        students_list.each do |student|
          user = User.with_email(student.email) || User.create!(email: student.email)
          user.regenerate_login_token if user.login_token.blank?

          startup = Startup.create!(
            name: student.name,
            level: first_level
          )

          founder = Founder.create!(user: user, name: student.name, startup: startup)
          founder.tag_list << tags
          founder.save!
        end
        school = @course.school
        school.founder_tag_list << tags
        school.save!
      end
    end
  end
end
