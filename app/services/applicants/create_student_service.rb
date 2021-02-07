module Applicants
  class CreateStudentService
    def initialize(applicant)
      @applicant = applicant
      @course = applicant.course
    end

    def create(tag)
      Applicant.transaction do
        student = create_new_student(tag)

        # Make sure the tag is in the school's list of founder tags.
        # This is useful for retrieval in the school admin interface.
        unless tag.in?(school.founder_tag_list)
          school.founder_tag_list.add(tag)
          school.save!
        end

        # Delete the applicant
        @applicant.destroy!

        student
      end
    end

    private

    def create_new_student(tag)
      # Create a user and generate a login token.
      user = school.users.with_email(@applicant.email).first_or_create!(email: @applicant.email, title: 'Student')
      user.regenerate_login_token if user.login_token.blank?
      user.update!(name: @applicant.name)

      # Create the team and tag it.
      team = Startup.create!(name: @applicant.name, level: first_level)
      team.tag_list.add(tag)
      team.save!

      # Finally, create a student profile for the user.
      Founder.create!(user: user, startup: team)
    end

    def school
      @school ||= @course.school
    end

    def first_level
      @first_level ||= @course.levels.find_by(number: 1)
    end
  end
end
