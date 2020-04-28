module Mutations
  class DeletePostLike < GraphQL::Schema::Mutation
    argument :post_id, ID, required: true

    description "Delete a like for some post"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeletePostLikeMutator.new(context, params)

      success = if mutator.valid?
        mutator.delete_post_like
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
