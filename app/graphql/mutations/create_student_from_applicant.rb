module Mutations
  class CreateStudentFromApplicant < ApplicationQuery
    include QueryAuthorizeSchoolAdmin

    argument :applicant_id, ID, required: true
    argument :title, String, required: false
    argument :affiliation, String, required: false
    argument :tags, [String], required: true
    argument :notify_student, Boolean, required: false

    description 'Create student from applicant record'

    field :success, Boolean, null: false

    def resolve(_params)
      convert_applicant
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.create_student_from_applicant.success_notification')
      )
      { success: true }
    end

    def convert_applicant
      Student.transaction do
        student =
          Applicants::CreateStudentService.new(applicant).create(@params[:tags])

        student.user.update!(
          title: @params[:title].presence || student.user.title,
          affiliation:
            @params[:affiliation].presence || student.user.affiliation
        )

        # rubocop:disable Lint/LiteralAsCondition
        if @params[:notify_student].presence || false
          StudentMailer.enrollment(student).deliver_later
        end
        # rubocop:enable Lint/LiteralAsCondition
      end
    end

    def resource_school
      applicant.course.school
    end

    def applicant
      Applicant.find_by(id: @params[:applicant_id], email_verified: true)
    end

    def allow_token_auth?
      true
    end
  end
end
