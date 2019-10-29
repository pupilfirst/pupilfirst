module Mutations
  class ArchiveCommunityResource < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :resource_type, String, required: true

    description "Archive community resources. Value of resourceType can be 'Question', 'Answer', or 'Comment'"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = ArchiveCommunityResourceMutator.new(context, params)

      if mutator.valid?
        mutator.archive
        { success: true }
      else
        raise "Invalid request. Errors: #{mutator.error_messages}"
      end
    end
  end
end
