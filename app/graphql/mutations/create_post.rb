module Mutations
  class CreatePost < GraphQL::Schema::Mutation
    argument :body, String, required: true
    argument :topic_id, ID, required: true
    argument :reply_to_post_id, ID, required: false

    description "Create a new post in a topic"

    field :post_id, ID, null: true

    def resolve(params)
      mutator = CreatePostMutator.new(context, params)

      post_id = if mutator.valid?
        mutator.notify(:success, "Done!", "Reply added successfully")
        mutator.create_post.id
      else
        mutator.notify_errors
        nil
      end

      { post_id: post_id }
    end
  end
end
