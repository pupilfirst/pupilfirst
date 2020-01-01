module TimelineEvents
  class CreateService
    def initialize(params, founder)
      @params = params
      @founder = founder
      @target = params[:target]
    end

    def execute
      TimelineEvent.transaction do
        TimelineEvent.create!(@params.merge(latest: true)).tap do |te|
          @founder.timeline_event_owners.create!(timeline_event: te)
          create_team_entries(te) if @params[:target].team_target?
          update_latest_flag(te)
        end
      end
    end

    private

    def create_team_entries(timeline_event)
      team_members.each do |member|
        member.timeline_event_owners.create!(timeline_event: timeline_event)
      end
    end

    def update_latest_flag(timeline_event)
      old_events = @target.timeline_events.joins(:timeline_event_owners)
        .where(timeline_event_owners: { founder: @founder.startup.founders })
        .where.not(id: timeline_event)

      old_events.where(latest: true).each do |submission|
        next if submission.founder_ids != @founder.startup.founder_ids

        submission.update!(latest: false)
      end
    end

    def team_members
      @founder.startup.founders - [@founder]
    end
  end
end
