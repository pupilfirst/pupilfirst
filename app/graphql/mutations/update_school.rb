module Mutations
  class UpdateSchool < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :about, String, required: true

    description "Update a School details"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateSchoolMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Details updated successfully!')
        mutator.update_school
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
