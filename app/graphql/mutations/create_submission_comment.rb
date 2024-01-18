module Mutations
  class CreateSubmissionComment < ApplicationQuery
    include QueryAuthorizeAuthor

    argument :comment, String, required: true
    argument :submission_id, String, required: true

    description "Create a submission comment"

    field :comment, Types::SubmissionCommentType, null: false

    def resolve(_params)
      comment =
        submission.submission_comments.create(
          comment: @params[:comment],
          user_id: current_user.id
        )
      notify(
        :success,
        I18n.t("shared.notifications.done_exclamation"),
        I18n.t("mutations.create_submission_comment.success_notification")
      )
      {
        comment: {
          id: comment.id,
          submission_id: comment.timeline_event_id,
          comment: comment.comment,
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

    def course
      submission&.course
    end
  end
end
