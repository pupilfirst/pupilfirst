module TimelineEvents
  # This service can be used to undo the effects of verifying a timeline event.
  class UndoVerificationService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def execute
      raise "TimelineEvent ##{@timeline_event.id} is pending, and cannot be processed" if @timeline_event.pending?

      TimelineEvent.transaction do
        unlink_startup_profile_submissions
        remove_karma_points
        remove_timeline_event_grades
        recompute_timeline_updated_on
        reverse_end_of_iteration unless @timeline_event.not_accepted?
        unlink_founder_resume if @timeline_event.verified?
        reset_timeline_event_status
      end
    end

    private

    # This removes the links to deck, wireframe, prototype, and video, if timeline event updated those.
    def unlink_startup_profile_submissions
      startup.update!(presentation_link: nil) if @timeline_event.timeline_event_type.new_deck?
      startup.update!(wireframe_link: nil) if @timeline_event.timeline_event_type.new_wireframe?
      startup.update!(prototype_link: nil) if @timeline_event.timeline_event_type.new_prototype?
      startup.update!(product_video_link: nil) if @timeline_event.timeline_event_type.new_video?
    end

    # Timeline event could have been awarded karma points. Remove those.
    def remove_karma_points
      @timeline_event.karma_point.destroy! if @timeline_event.karma_point.present?
    end

    # Startup's timeline_updated_on could have been updated. Recompute that.
    def recompute_timeline_updated_on
      return unless startup.timeline_updated_on == @timeline_event.event_on

      other_latest_timeline_event = startup.timeline_events.verified_or_needs_improvement
        .where.not(id: @timeline_event.id).order(event_on: :DESC).first

      if other_latest_timeline_event.present?
        startup.timeline_updated_on = other_latest_timeline_event.event_on
        startup.save!
      end
    end

    # Ff event was of iteration ending type, the startup would have been moved into a different level (restart), and its
    # iteration count would be incremented.
    #
    # We do know which level he was at previously, so all we can do at this point is decrement the iteration count.
    def reverse_end_of_iteration
      return unless @timeline_event.end_iteration?
      return unless startup.iteration > 1

      startup.iteration = startup.iteration - 1
      startup.save!
    end

    # Unlink / remove founder resume if it was a resume submission.
    def unlink_founder_resume
      return unless @timeline_event.timeline_event_type.resume_submission?

      founder.resume_file = nil
      founder.resume_url = nil
      founder.save!
    end

    # Reset the status of timeline event to pending.
    def reset_timeline_event_status
      @timeline_event.status = TimelineEvent::STATUS_PENDING
      @timeline_event.status_updated_at = Time.zone.now
      @timeline_event.grade = nil
      @timeline_event.score = nil
      @timeline_event.save!
    end

    def startup
      @startup ||= @timeline_event.startup
    end

    def founder
      @founder ||= @timeline_event.founder
    end

    def remove_timeline_event_grades
      @timeline_event.timeline_event_grades.destroy_all
    end
  end
end
