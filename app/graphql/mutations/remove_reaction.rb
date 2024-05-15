module Mutations
  class RemoveReaction < ApplicationQuery
    argument :reaction_id, String, required: true

    description "Remove a reaction from either a submission or comment"

    field :success, Boolean, null: false

    def resolve(_params)
      reaction.delete
      { success: true }
    end

    def query_authorized?
      reaction.user_id == current_user.id
    end

    def reaction
      @reaction ||= Reaction.find_by(id: @params[:reaction_id])
      raise GraphQL::ExecutionError, I18n.t("mutations.remove_reaction.reaction_not_found") if @reaction.nil?
      @reaction
    end
  end
end
