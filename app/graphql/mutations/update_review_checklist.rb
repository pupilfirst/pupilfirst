module Mutations
  class UpdateReviewChecklist < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :review_checklist, GraphQL::Types::JSON, required: true

    description "Update review checklist"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateReviewChecklistMutator.new(context, params)

      if mutator.valid?
        mutator.update_review_checklist
        mutator.notify(:success, "Success", "Review checklist updated successfully")
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end
