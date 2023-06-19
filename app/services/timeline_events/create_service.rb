module TimelineEvents
  class CreateService
    def initialize(
      params,
      founder,
      notification_service: Developers::NotificationService.new
    )
      @params = params
      @founder = founder
      @target = params[:target]
      @notification_service = notification_service
    end

    def execute
      submission =
        TimelineEvent.transaction do
          timeline_event_params =
            (
              if @target.evaluation_criteria.blank?
                @params.merge(passed_at: Time.zone.now)
              else
                @params
              end
            )
          TimelineEvent
            .create!(timeline_event_params)
            .tap do |s|
              @founder.timeline_event_owners.create!(
                timeline_event: s,
                latest: true
              )

              create_team_entries(s) if @params[:target].team_target?

              update_latest_flag(s)
            end
        end

      submission_event_type =
        if @target.evaluation_criteria.blank?
          TimelineEvents::AfterMarkingAsCompleteJob.perform_later(submission)
          :submission_automatically_verified
        else
          :submission_created
        end

      @notification_service.execute(
        @founder.course,
        submission_event_type,
        @founder.user,
        submission
      )

      if submission.target.action_config.present?
        Github::RunActionsJob.perform_later(submission)
        SubmissionReport.create!(
          submission_id: submission.id,
          reporter: SubmissionReport::VIRTUAL_TEACHING_ASSISTANT,
          status: SubmissionReport.statuses[:queued],
          target_url: submission.actions_url
        )
      end

      submission
    end

    private

    def create_team_entries(timeline_event)
      team_members.each do |member|
        member.timeline_event_owners.create!(
          timeline_event: timeline_event,
          latest: true
        )
      end
    end

    def update_latest_flag(timeline_event)
      TimelineEventOwner.where(
        timeline_event_id: old_events(timeline_event).live,
        founder: owners
      ).update_all(latest: false) # rubocop:disable Rails/SkipsModelValidations
    end

    def owners
      if (@target.team_target? && @founder.team)
        @founder.team.founders
      else
        @founder
      end
    end

    def team_members
      @founder.team ? @founder.team.founders - [@founder] : []
    end

    def old_events(timeline_event)
      @target
        .timeline_events
        .joins(:timeline_event_owners)
        .where(timeline_event_owners: { founder: owners })
        .where.not(id: timeline_event)
    end
  end
end
