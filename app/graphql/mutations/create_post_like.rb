module Mutations
  class CreatePostLike < GraphQL::Schema::Mutation
    argument :post_id, ID, required: true

    description "Add a like for the post"

    field :post_like_id, ID, null: true

    def resolve(params)
      mutator = CreatePostLikeMutator.new(context, params)

      post_like_id = if mutator.valid?
        mutator.create_post_like.id
      else
        mutator.notify_errors
        nil
      end

      { post_like_id: post_like_id }
    end
  end
end
