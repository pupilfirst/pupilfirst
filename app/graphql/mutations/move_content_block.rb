module Mutations
  class MoveContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :direction, Types::MoveDirectionType, required: true

    description "Move a content block in a target up or down"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = MoveContentBlockMutator.new(context, params)

      success = if mutator.valid?
        mutator.move_content_block
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end
