module Mutations
  class MergeCohort < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :delete_cohort_id, ID, required: true
    argument :merge_into_cohort_id, ID, required: true

    description 'Merge cohorts'

    field :success, Boolean, null: false

    class CohortsShouldBeDifferent < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        if value[:delete_cohort_id] == value[:merge_into_cohort_id]
          return 'Cohorts should be different'
        end
      end
    end

    validates CohortsShouldBeDifferent => {}

    def resolve(_params)
      Cohorts::MergeService.new(cohort_to_delete).merge_into(merge_into_cohort)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.merge_cohort.success_notification')
      )
      { success: true }
    end

    def cohort_to_delete
      current_school.cohorts.find(@params[:delete_cohort_id])
    end

    def merge_into_cohort
      cohort_to_delete&.course&.cohorts&.find(@params[:merge_into_cohort_id])
    end

    def resource_school
      cohort_to_delete&.school
    end
  end
end
