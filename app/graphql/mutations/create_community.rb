module Mutations
  class CreateCommunity < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :target_linkable, Boolean, required: true
    argument :course_ids, [ID], required: false

    description "Create a new community"

    field :id, String, null: true

    def resolve(params)
      mutator = CreateCommunityMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, "Success", "Community created successfully.")
        { id: mutator.create_community.id }
      else
        mutator.notify_errors
        { id: nil }
      end
    end
  end
end
