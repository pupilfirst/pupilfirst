module Mutations
  class CreateCommunity < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :target_linkable, Boolean, required: true
    argument :course_ids, [ID], required: false

    description "Create a new community"

    field :community_id, ID, null: true
    field :errors, [Types::CreateCommunityErrors], null: true

    def resolve(params)
      mutator = CreateCommunityMutator.new(context, params)

      if mutator.valid?
        { community_id: mutator.create_community, errors: nil }
      else
        { community_id: nil, errors: mutator.error_messages }
      end
    end
  end
end
