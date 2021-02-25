module Mutations
  class CreateApplicant < GraphQL::Schema::Mutation
    argument :course_id, ID, required: true
    argument :email, String, required: true
    argument :name, String, required: true

    description 'Create a new applicant'

    field :success, Boolean, null: false
    field :redirect_url, String, null: true

    def resolve(params)
      mutator = CreateApplicantMutator.new(context, params)

      if mutator.valid?
        {
          success: mutator.create_applicant,
          redirect_url: mutator.redirect_url
        }
      else
        mutator.notify_errors
        { success: false, redirect_url: nill }
      end
    end
  end
end
