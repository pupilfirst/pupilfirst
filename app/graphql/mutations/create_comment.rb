module Mutations
  class CreateComment < GraphQL::Schema::Mutation
    argument :value, String, required: true
    argument :commentable_type, String, required: true
    argument :commentable_id, ID, required: true

    description "Create a comment."

    field :comment_id, ID, null: true
    field :errors, [Types::CreateCommentErrors], null: true

    def resolve(params)
      mutator = CreateCommentMutator.new(context, params)

      if mutator.valid?
        { comment_id: mutator.create_comment, errors: nil }
      else
        { comment_id: nil, errors: mutator.error_messages }
      end
    end
  end
end
