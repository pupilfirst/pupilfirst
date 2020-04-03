module Mutations
  class UpdatePost < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :body, String, required: true

    description "Update community post"

    field :success, Boolean, null: true

    def resolve(params)
      mutator = UpdatePostMutator.new(context, params)

      success = if mutator.valid?
        mutator.update_post
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
