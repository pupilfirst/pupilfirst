module Mutations
  class DeleteCoachTeamEnrollment < GraphQL::Schema::Mutation
    argument :coach_id, ID, required: true
    argument :team_id, ID, required: true

    description "Deletes an assigned team for a coach"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteCoachTeamEnrollmentMutator.new(context, params)

      if mutator.valid?
        mutator.delete_coach_team_enrollment
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
