module Mutations
  class CreatePostLike < GraphQL::Schema::Mutation
    argument :post_id, ID, required: true

    description "Add a like for the post"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreatePostLikeMutator.new(context, params)

      success = if mutator.valid?
        mutator.create_post_like
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
