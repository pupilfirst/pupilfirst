module Mutations
  class CreateCommunity < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :target_linkable, Boolean, required: true
    argument :course_ids, [ID], required: false
    argument :topic_categories, [String], required: true

    description "Create a new community"

    field :community, Types::CommunityType, null: true

    def resolve(params)
      mutator = CreateCommunityMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, "Success", "Community created successfully.")
        { community: mutator.create_community }
      else
        mutator.notify_errors
        { community: nil }
      end
    end
  end
end
