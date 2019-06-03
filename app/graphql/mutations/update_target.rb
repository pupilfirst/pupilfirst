module Mutations
  class UpdateTarget < GraphQL::Schema::Mutation
    argument :title, String, required: true
    argument :role, String, required: true
    argument :target_action_type, String, required: true

    description "Update a target."

    field :target, Types::CourseType, null: false

    def resolve(params)
      mutator = UpdateTargetMutator.new(params, context)

      if mutator.valid?
        { course: mutator.create_course, errors: [] }
      else
        { course: nil, errors: mutator.error_codes }
      end
    end
  end
end
