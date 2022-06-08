module Mutations
  class MergeCohort < ApplicationQuery
    argument :delete_cohort_id, ID, required: true
    argument :merge_into_cohort_id, ID, required: true, validates: {inclusion: {in: }}

    description 'Merge cohorts'

    field :cohort, Types::CohortType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.update_cohort.success_notification')
      )

      { success: merge_cohorts }
    end

    def merge_cohorts
      cohort.update!(
        name: @params[:name],
        description: @params[:description],
        ends_at: @params[:ends_at]
      )
    end

    def cohort_to_delete
      current_school.cohorts.find(@params[:delete_cohort_id])
    end

    def course_cohorts
      cohort_to_delete&.course
    end

    def merge_into_cohort
      cohort_to_delete&.course.cohorts.find(@params[:merge_into_cohort_id])
    end

    def resource_school
      cohort_to_delete&.school
    end
  end
end
