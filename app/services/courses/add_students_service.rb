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

          create_user_profile(user, student.name)
          startup = Startup.create!(name: student.name, level: first_level)

          founder = Founder.create!(user: user, startup: startup)
          founder.tag_list << student.tags
          founder.save!
        end
        # Add the tags to the school's list of founder tags. This is useful for retrieval in the school admin interface.
        all_student_tags = students_list.map { |student| student.tags || [] }.flatten.uniq
        school.founder_tag_list << all_student_tags
        school.save!
      end
    end

    private

    def school
      @school ||= @course.school
    end

    def create_user_profile(user, name)
      user_profile = UserProfile.where(user: user, school: school).first_or_create!
      user_profile.update!(name: name)
    end
  end
end
