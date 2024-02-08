module Mutations
  class PinSubmission < ApplicationQuery
    argument :pinned, Boolean, required: true
    argument :submission_id, String, required: true

    description "Pin or unpin a submission"

    field :success, Boolean, null: false

    def resolve(_params)
      submission.pinned = @params[:pinned]
      submission.save!
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
      @submission ||= TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
