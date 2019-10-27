module Mutations
  class DeleteSchoolAdmin < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Delete a school admin"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteSchoolAdminMutator.new(context, params)

      success = if mutator.valid?
        mutator.delete_school_admin
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
