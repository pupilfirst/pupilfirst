module Startups
  # Add starter timeline events to a startup's timeline.
  class PrepopulateTimelineService
    def initialize(startup)
      @startup = startup
    end

    def execute
      %w(joined_svco).each do |type|
        @startup.timeline_events.create!(
          founder: @startup.admin,
          timeline_event_type: TimelineEventType.find_by(key: type),
          auto_populated: true,
          image: File.open("#{Rails.root}/app/assets/images/timeline/joined_svco_cover.png"),
          verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED,
          verified_at: Time.now,
          event_on: Time.now
        )
      end
    end
  end
end
