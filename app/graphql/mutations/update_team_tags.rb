module Mutations
  class UpdateTeamTags < GraphQL::Schema::Mutation
    argument :tags, [String], required: false
    argument :team_id, ID, required: true

    description "Update team tags."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateTeamTagsMutator.new(context, params)

      success = if mutator.valid?
        mutator.update_team_tags
        mutator.notify(:success, "Success", "Tags updated successfully")
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
