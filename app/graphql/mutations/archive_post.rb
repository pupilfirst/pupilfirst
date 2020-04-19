module Mutations
  class ArchivePost < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Archive a community post"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = ArchivePostMutator.new(context, params)

      success = if mutator.valid?

        mutator.archive_post
        mutator.notify(:success, "Done!", "Post archived successfully")
        true
      else
        false
      end

      { success: success }
    end
  end
end
