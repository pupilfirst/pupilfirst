module Mutations
  class CreateModerationReport < ApplicationQuery
    argument :reason, String, required: true
    argument :reportable_id, String, required: true
    argument :reportable_type, String, required: true

    description "Create a moderation report on either a submission or comment"

    field :moderation_report, Types::ModerationReportType, null: false

    def resolve(_params)
      moderation_report =
        ModerationReport.create(
          reason: @params[:reason],
          reportable_id: @params[:reportable_id],
          reportable_type: @params[:reportable_type],
          user_id: current_user.id
        )

      SchoolContactMailer.moderation_report(
        moderation_report,
        submission
      ).deliver_later

      UserMailer.confirm_moderation_report(
        moderation_report,
        submission
      ).deliver_later

      { moderation_report: moderation_report }
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
      if @params[:reportable_type] == "TimelineEvent"
        @submission ||= TimelineEvent.find_by(id: @params[:reportable_id])
      else
        @submission ||= submission_comment.submission
      end
    end

    def submission_comment
      @submission_comment ||=
        SubmissionComment.find_by(id: @params[:reportable_id])
    end

    def reported_item
      if @params[:reportable_type] == "TimelineEvent"
        submission
      else
        submission_comment
      end
    end

    def course
      @course ||= submission&.course
    end
  end
end
