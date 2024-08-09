module Coaches
  class RepeatRejectionsAlertService
    def initialize(submission)
      @submission = submission
    end

    def execute
      # Deactivate this feature if the threshold is set to 0.
      return if repeat_rejection_threshold.zero?

      # Do not send alerts if the current submission was reviewed by a human.
      return unless @submission.evaluator_id.in?(bot_evaluator_ids)

      # Send alerts only on multiples of a positive threshold number.
      if current_submission_rejection_count % repeat_rejection_threshold != 0
        return
      end

      coaches.each do |coach|
        CoachMailer.repeat_rejections_alert(
          coach,
          @submission,
          current_submission_rejection_count
        ).deliver_later
      end
    end

    def coaches
      @submission.target.course.faculty.where.not(id: bot_evaluator_ids)
    end

    def current_submission_rejection_count
      @current_submission_rejection_count ||=
        @submission
          .students
          .first
          .timeline_events
          .where(target_id: @submission.target)
          .where(evaluator_id: bot_evaluator_ids)
          .failed
          .count
    end

    def repeat_rejection_threshold
      Settings.bot.evaluator_repeat_rejection_alert_threshold
    end

    def bot_evaluator_ids
      Settings.bot.evaluator_ids
    end
  end
end
