module Mutations
  class CreateReaction < ApplicationQuery
    include QueryAuthorizeAuthor

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
          reactionable_id: reaction.reactionable_id,
          reactionable_type: reaction.reactionable_type,
          reaction_value: reaction.reaction_value,
          user_name: current_user.name
        }
      }
    end

    def resource_school
      course&.school
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

    def submission_comment
      @submission_comment ||=
        SubmissionComment.find_by(id: @params[:comment_id])
    end

    def course
      submission&.course
    end
  end
end
