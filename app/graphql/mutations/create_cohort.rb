module Mutations
  class CreateCohort < ApplicationQuery
    include QueryAuthorizeSchoolAdmin
    argument :course_id, ID, required: false
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
                 minimum: 1,
                 maximum: 250
               },
               allow_blank: true
             }
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: false

    description 'Create a new cohort'

    field :cohort, Types::CohortType, null: true

    def resolve(_params)
      notify(
        :success,
        I18n.t('shared.notifications.done_exclamation'),
        I18n.t('mutations.create_cohort.success_notification')
      )

      { cohort: create_cohort }
    end

    def create_cohort
      course.cohorts.create!(
        name: @params[:name],
        description: @params[:description],
        ends_at: @params[:ends_at]
      )
    end

    def course
      @course ||= current_school.courses.find(@params[:course_id])
    end

    def resource_school
      course&.school
    end
  end
end
