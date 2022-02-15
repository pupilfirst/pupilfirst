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
          TimelineEvent
            .create!(@params)
            .tap do |s|
              @founder.timeline_event_owners.create!(
                timeline_event: s,
                latest: true
              )

              create_team_entries(s) if @params[:target].team_target?

              update_latest_flag(s)
            end
        end

      @notification_service.execute(
        @founder.course,
        :submission_created,
        @founder.user,
        submission
      )

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
      TimelineEventOwner
        .where(
          timeline_event_id: old_events(timeline_event).live,
          founder: owners
        )
        .update_all(latest: false) # rubocop:disable Rails/SkipsModelValidations
    end

    def owners
      @target.team_target? ? @founder.startup.founders : @founder
    end

    def team_members
      @founder.startup.founders - [@founder]
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
