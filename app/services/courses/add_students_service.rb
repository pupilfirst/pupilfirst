module Courses
  class AddStudentsService
    def initialize(course)
      @course = course
    end

    def add(students_list, team_name = nil)
      first_level = @course.levels.find_by(number: 1)
      team_name = students_list.first.name if team_name.blank?

      Course.transaction do
        team = Startup.create!(product_name: team_name, level: first_level)

        students_list.each do |student|
          user = User.with_email(student.email) || User.create!(email: student.email)
          user.regenerate_login_token if user.login_token.blank?
          Founder.create!(user: user, name: student.name, startup: team)
        end
      end
    end
  end
end
