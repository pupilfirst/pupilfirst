module Mutations
  class RemoveReaction < ApplicationQuery
    argument :reaction_id, String, required: true

    description "Remove a reaction from either a submission or comment"

    field :success, Boolean, null: false

    def resolve(_params)
      reaction.delete
      { success: true }
    end

    class ValidateReactionExists < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        if !Reaction.exists?(id: value[:reaction_id])
          return(
            I18n.t("mutations.remove_reaction.reaction_not_found")
          )
        end
      end
    end

    validates ValidateReactionExists => {}

    def query_authorized?
      reaction.user_id == current_user.id
    end

    def reaction
      @reaction ||= Reaction.find_by(id: @params[:reaction_id])
    end
  end
end
