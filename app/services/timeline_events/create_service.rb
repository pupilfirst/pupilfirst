module TimelineEvents
  class CreateService
    def initialize(params, founder)
      @params = params
      @founder = founder
      @target = params[:target]
    end

    def execute
      te = TimelineEvent.create!(@params)
      @founder.timeline_event_owners.create!(timeline_event: te)
      create_team_entries(te) if @params[:target].team_target?
      update_latest_flag(te)
      te
    end

    private

    def create_team_entries(timeline_event)
      team_members.each do |member|
        member.timeline_event_owners.create!(timeline_event: timeline_event)
      end
    end

    def update_latest_flag(timeline_event)
      timeline_event.update!(latest: true)
      old_events = @target.timeline_events.joins(:timeline_event_owners).where(timeline_event_owners: { founder: @founder.startup.founders }) - [timeline_event]
      if old_events.present?
        old_events.each do |event|
          event.update!(latest: false)
        end
      end
    end

    def team_members
      @founder.startup.founders - [@founder]
    end
  end
end
