module Mutations
  class LevelUp < GraphQL::Schema::Mutation
    argument :course_id, ID, required: true

    description "Level up"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = LevelUpMutator.new(context, params)

      if mutator.valid?
        { success: mutator.execute }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
