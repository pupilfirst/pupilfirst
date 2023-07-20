module Mutations
  class UpdateStudentDetails < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :id, ID, required: true
    argument :cohort_id, ID, required: true
    argument :coach_ids, [ID], required: true
    argument :name, String, required: true
    argument :title, String, required: true
    argument :affiliation, String, required: false
    argument :taggings, [String], required: true

    description "Update details of a student"

    field :success, Boolean, null: false

    def resolve(_params)
      update_student_details
      notify(
        :success,
        I18n.t("shared.notifications.success"),
        I18n.t("mutations.update_student_details.success_notification")
      )
      { success: true }
    end

    class ValidateUpdateStudentDetils < GraphQL::Schema::Validator
      include ValidatorCombinable

      def validate(_object, context, value)
        @cohort =
          context[:current_school].cohorts.find_by(id: value[:cohort_id])
        @student = context[:current_school].students.find_by(id: value[:id])
        @coaches = @student.course.faculty.where(id: value[:coach_ids])
        @value = value

        combine(
          strings_must_not_be_too_long,
          cohort_should_belong_to_the_same_course,
          coaches_should_belong_to_the_same_course
        )
      end

      def valid_string?(string:, max_length:, optional: false)
        return true if string.blank? && optional
        string.length <= max_length
      end

      def strings_must_not_be_too_long
        if valid_string?(string: @value[:name], max_length: 250) &&
             valid_string?(
               string: @value[:title],
               max_length: 250,
               optional: true
             ) &&
             valid_string?(
               string: @value[:affiliation],
               max_length: 250,
               optional: true
             )
          return
        end

        "One or more of the entries have invalid strings"
      end

      def cohort_should_belong_to_the_same_course
        return if @student.course.cohorts.include?(@cohort)

        "The cohort does not belong to the same course"
      end

      def coaches_should_belong_to_the_same_course
        return if @coaches.count == @value[:coach_ids].count

        "One or more of the coaches do not belong to the same course"
      end
    end

    validates ValidateUpdateStudentDetils => {}

    private

    def update_student_details
      if student&.name != @params[:name].strip
        Users::LogUsernameUpdateService.new(
          current_user,
          @params[:name],
          student.user
        ).execute
      end
      Student.transaction do
        student.user.update!(
          name: @params[:name],
          title: @params[:title],
          affiliation: @params[:affiliation]
        )

        student.tag_list = @params[:taggings]

        if student.cohort != cohort
          student.team_id = nil
          student.cohort = cohort
        end

        student.save!

        resource_school.student_tag_list << @params[:taggings]
        resource_school.save!

        if @params[:coach_ids].present?
          ::Students::AssignReviewerService
            .new(student)
            .assign(@params[:coach_ids])
        end
      end
    end

    def resource_school
      course&.school
    end

    def course
      @course ||= student&.course
    end

    def cohort
      @cohort ||= course.cohorts.find_by(id: @params[:cohort_id])
    end

    def student
      @student ||= Student.find_by(id: @params[:id])
    end
  end
end
