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

      if submission.students.pluck(:user_id).exclude?(current_user.id)
        StartupMailer.comment_on_submission(
          submission,
          comment,
          current_user
        ).deliver_later
      end

      Notifications::CreateJob.perform_later(
        :submission_comment_created,
        current_user,
        comment
      )

      { comment: comment }
    end

    def query_authorized?
      return false if current_user.blank?

      return false if course&.school != current_school

      return true if current_school_admin.present?

      return true if current_user.course_authors.where(course: course).present?

      return true if course.faculty.exists?(user: current_user)

      student.present?
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
