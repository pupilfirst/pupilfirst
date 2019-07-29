module Mutations
  class CreateApplicant < GraphQL::Schema::Mutation
    argument :course_id, ID, required: true
    argument :email, String, required: true

    description "Create a new applicant"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateApplicantMutator.new(params, context)

      if mutator.valid?
        { success: mutator.save }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
