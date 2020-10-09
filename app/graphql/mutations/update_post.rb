module Mutations
  class UpdatePost < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :body, String, required: true
    argument :edit_reason, String, required: false
    description "Update community post"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdatePostMutator.new(context, params)

      success = if mutator.valid?
        post = mutator.update_post
        post_type = post.post_number == 1 ? "Post" : "Reply"
        mutator.notify(:success, "Done!", "#{post_type} updated successfully")

        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
