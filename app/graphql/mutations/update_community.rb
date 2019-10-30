module Mutations
  class UpdateCommunity < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :target_linkable, Boolean, required: true
    argument :course_ids, [ID], required: false

    description "Update a new community"

    field :community_id, ID, null: true
    field :errors, [Types::UpdateCommunityErrors], null: true

    def resolve(params)
      mutator = UpdateCommunityMutator.new(context, params)

      if mutator.valid?
        { community_id: mutator.update_community, errors: nil }
      else
        { community_id: nil, errors: mutator.error_messages }
      end
    end
  end
end
