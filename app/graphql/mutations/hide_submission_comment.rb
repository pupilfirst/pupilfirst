module Mutations
  class HideSubmissionComment < ApplicationQuery
    argument :submission_comment_id, String, required: true
    argument :hide, Boolean, required: true

    description "Hide or unhide a submission comment from discussion"

    field :success, Boolean, null: false

    def resolve(_params)
      if @params[:hide]
        submission_comment.hidden_at = Time.zone.now
        submission_comment.hidden_by = current_user
      else
        submission_comment.hidden_at = nil
        submission_comment.hidden_by = nil
      end

      submission_comment.save!
      { success: true }
    end

    def query_authorized?
      return false if current_user.blank?

      # school admin or course author
      if current_school_admin.present? ||
           current_user.course_authors.where(course: course).present?
        return true
      end

      # faculty of the course
      current_user.faculty&.cohorts&.exists?(id: student.cohort_id)
    end

    def submission
      @submission ||= submission_comment.timeline_event
    end

    def submission_comment
      @submission_comment ||=
        SubmissionComment.find_by(id: @params[:submission_comment_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
