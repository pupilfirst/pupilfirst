module Mutations
  class DestroySchoolLink < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Destroy a school link."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DestroySchoolLinkMutator.new(params, context)

      if mutator.valid?
        mutator.destroy_school_link
        { success: true }
      else
        raise "Invalid request. Errors: #{mutator.error_codes}"
      end
    end
  end
end
