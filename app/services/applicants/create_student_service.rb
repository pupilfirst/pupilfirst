module Applicants
  class CreateStudentService
    def initialize(applicant)
      @applicant = applicant
      @course = applicant.course
    end

    def execute
      Applicant.transaction do
        founder = create_new_student
        # Add the tags to the school's list of founder tags. This is useful for retrieval in the school admin interface.
        school.founder_tag_list << founder.tag_list
        school.save!
        # Delete the applicant
        @applicant.destroy

        founder.user
      end
    end

    private

    def create_new_student
      # Create a user and generate a login token.
      user = User.where(email: @applicant.email, school: school).first_or_create!
      user.regenerate_login_token if user.login_token.blank?
      user.update!(name: @applicant.name)

      startup = Startup.create!(name: @applicant.name, level: first_level)

      # Finally, create a student profile for the user and tag it.
      founder = Founder.create!(user: user, startup: startup)
      founder.tag_list << "Public Signup"
      founder.save!
      founder
    end

    def school
      @school ||= @course.school
    end

    def first_level
      @first_level ||= @course.levels.find_by(number: 1)
    end
  end
end
