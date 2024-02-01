module Mutations
  class CreateReaction < ApplicationQuery
    argument :reaction_value, String, required: true
    argument :reactionable_id, String, required: true
    argument :reactionable_type, String, required: true

    description "Create a reaction on either a submission or comment"

    field :reaction, Types::ReactionType, null: false

    def resolve(_params)
      reaction =
        Reaction.create(
          reaction_value: @params[:reaction_value],
          reactionable_id: @params[:reactionable_id],
          reactionable_type: @params[:reactionable_type],
          user_id: current_user.id
        )
      {
        reaction: {
          id: reaction.id,
          user_id: reaction.user_id,
          reactionable_id: reaction.reactionable_id,
          reactionable_type: reaction.reactionable_type,
          reaction_value: reaction.reaction_value,
          user_name: current_user.name
        }
      }
    end

    #TODO implement authorization
    def query_authorized?
      return true
    end

    def submission
      if @params[:reactionable_type] == "TimelineEvent"
        @submission ||= TimelineEvent.find_by(id: @params[:reactionable_id])
      else
        @submission ||=
          SubmissionComment.find_by(
            id: @params[:reactionable_id]
          ).timeline_event
      end
    end

    def course
      @course ||= submission&.course
    end
  end
end
