module Mutations
  class CreateReaction < ApplicationQuery
    include QueryAuthorizeAuthor

    argument :reaction_value, String, required: true
    argument :submission_id, String, required: true
    argument :comment_id, String, required: false

    description "Create a reaction on either a submission or comment"

    field :reaction, Types::ReactionType, null: false

    def resolve(_params)
      if @params[:comment_id].present?
        reaction =
          submission_comment.reactions.create(
            reaction_value: @params[:reaction_value],
            user_id: current_user.id
          )
      else
        reaction =
          submission.reactions.create(
            reaction_value: @params[:reaction_value],
            user_id: current_user.id
          )
      end
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
      @submission ||= TimelineEvent.find_by(id: @params[:submission_id])
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
