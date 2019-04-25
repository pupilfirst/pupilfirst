module Mutations
  class UpdateSchoolString < GraphQL::Schema::Mutation
    argument :key, String, required: true
    argument :value, String, required: false

    description "Update a school string."

    field :errors, [Types::UpdateSchoolStringError], null: false

    def resolve(params)
      mutator = UpdateSchoolStringMutator.new(params, context)

      if mutator.valid?
        mutator.update_school_string
        { errors: [] }
      else
        { errors: mutator.error_codes }
      end
    end
  end
end
