module Applicants
  class CreateStudentService
    def initialize(applicant)
      @applicant = applicant
      @course = applicant.course
      @cohort = @course.default_cohort
    end

    def create(tags)
      if @cohort.blank?
        raise "Default Cohort Assignment is required to onboard applicants"
      end

      Applicant.transaction do
        student = create_new_student(tags)

        # Make sure the tag is in the school's list of student tags.
        # This is useful for retrieval in the school admin interface.
        tags_to_add = tags.select { |tag| !tag.in?(school.student_tag_list) }

        unless tags.empty?
          school.student_tag_list.add(tags_to_add)
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
      user = school.users.with_email(@applicant.email).first
      user =
        User.create!(
          school: school,
          email: @applicant.email,
          title: "Student"
        ) if user.nil?
      user.regenerate_login_token
      user.update!(name: @applicant.name)

      # Finally, create a student profile for the user.
      student = Student.create!(user: user, cohort: @cohort)
      student.tag_list.add(tags)
      student.save!
      student
    end

    def school
      @school ||= @course.school
    end
  end
end
