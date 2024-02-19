module Mutations
  class HideSubmission < ApplicationQuery
    argument :submission_id, String, required: true
    argument :hide, Boolean, required: true

    description "Hide or unhide a submission from discussion"

    field :success, Boolean, null: false

    def resolve(_params)
      if @params[:hide]
        submission.hidden_at = Time.zone.now
        submission.hidden_by = current_user
      else
        submission.hidden_at = nil
        submission.hidden_by = nil
      end

      submission.save!
      { success: true }
    end

    def query_authorized?
      return false if current_user.blank?

      # school admin or course author
      return true if current_school_admin.present?

      # faculty of the course
      current_user.faculty&.cohorts&.exists?(id: student.cohort_id)
    end

    def submission
      @submission ||= TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
