module Applicants
  class CreateStudentService
    def initialize(applicant)
      @applicant = applicant
      @course = applicant.course
    end

    def create(tags)
      Applicant.transaction do
        student = create_new_student(tags)

        # Make sure the tag is in the school's list of founder tags.
        # This is useful for retrieval in the school admin interface.
        tags_to_add = tags.select { |tag| !tag.in?(school.founder_tag_list) }

        unless tags.empty?
          school.founder_tag_list.add(tags_to_add)
          school.save!
        end

        # Delete the applicant
        @applicant.destroy!

        student
      end
    end

    private

    def create_new_student(tags)
      # Create a user and generate a login token.
      user =
        school
          .users
          .with_email(@applicant.email)
          .first_or_create!(email: @applicant.email, title: 'Student')
      user.regenerate_login_token
      user.update!(name: @applicant.name)

      # Create the team and tag it.
      team = Startup.create!(name: @applicant.name, level: first_level)
      team.tag_list.add(tags)
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
