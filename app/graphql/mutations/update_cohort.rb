module Mutations
  class UpdateCohort < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :cohort_id, ID, required: false
    argument :name,
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 100
               }
             }
    argument :description,
             String,
             required: false,
             validates: {
               length: {
                 minimum: 2,
                 maximum: 250
               },
               allow_blank: true
             }
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: false

    description "Update a cohort"

    field :cohort, Types::CohortType, null: false

    def resolve(_params)
      if update_cohort
        notify(
          :success,
          I18n.t("shared.notifications.done_exclamation"),
          I18n.t("mutations.update_cohort.success_notification")
        )
      else
        notify(
          :error,
          I18n.t("shared.notifications.error"),
          cohort.errors.full_messages.join(", ")
        )
      end

      { cohort: }
    end

    def update_cohort
      cohort.update(
        name: @params[:name],
        description: @params[:description],
        ends_at: @params[:ends_at]
      )
    end

    def cohort
      @cohort ||= current_school.cohorts.find(@params[:cohort_id])
    end

    def resource_school
      cohort&.school
    end
  end
end
