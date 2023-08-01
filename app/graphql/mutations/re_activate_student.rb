module Mutations
  class ReActivateStudent < ApplicationQuery
    include QueryAuthorizeSchoolAdmin

    description 'Re-activate student in a course'

    argument :id, ID, required: true

    field :success, Boolean, null: false

    def resolve(_params)
      student.update!(dropped_out_at: nil)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.re_activate_student.success_notification')
      )
      { success: true }
    end

    class ValidateStudentStatus < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        @student = Student.find_by(id: value[:id])

        return if @student.dropped_out_at?

        'Student is not dropped out'
      end
    end

    validates ValidateStudentStatus => {}

    private

    def resource_school
      student.school
    end

    def student
      @student ||= Student.find_by(id: @params[:id])
    end
  end
end
