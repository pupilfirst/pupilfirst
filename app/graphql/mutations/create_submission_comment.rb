module Mutations
  class CreateSubmissionComment < ApplicationQuery
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
      { comment: comment }
    end

    def query_authorized?
      return false if current_user.blank?

      # school admin or course author
      if current_school_admin.present? ||
           current_user.course_authors.where(course: course).present?
        return true
      end

      # faculty of the course
      return true if course.faculty.exists?(user: current_user)

      # student of the course
      current_user.id == student&.user_id
    end

    def student
      @student ||=
        current_user
          .students
          .joins(:cohort)
          .find_by(cohorts: { course_id: course })
    end

    def submission
      @submission ||= TimelineEvent.find_by(id: @params[:submission_id])
    end

    def course
      @course ||= submission&.course
    end
  end
end
