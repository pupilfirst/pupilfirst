module Mutations
  class UnmarkPostAsSolution < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Unmark a community post as a solution"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UnmarkPostAsSolutionMutator.new(context, params)

      success = if mutator.valid?
        mutator.unmark_post_as_solution
        mutator.notify(:success, "Done!", "Reply unmarked as solution!")
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
