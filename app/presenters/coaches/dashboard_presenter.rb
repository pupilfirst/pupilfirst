module Coaches
  class DashboardPresenter < ApplicationPresenter
    def react_props
      {
        coach: { name: current_coach.name, id: current_coach.id },
        startups: startups,
        timelineEvents: timeline_events
      }
    end

    private

    def current_coach
      @current_coach ||= view.current_coach
    end

    def startups
      @startups ||= begin
        current_coach.startups.map { |startup| { name: startup.product_name, id: startup.id } }
      end
    end

    def timeline_events
      TimelineEvent.where(startup: current_coach.startups).includes(:founder, :startup).map do |timeline_event|
        {
          id: timeline_event.id,
          title: timeline_event.title,
          description: timeline_event.description,
          eventOn: timeline_event.event_on,
          status: timeline_event.status,
          startupId: timeline_event.startup_id,
          startupName: timeline_event.startup.product_name,
          founderId: timeline_event.founder_id,
          founderName: timeline_event.founder.name,
          submittedAt: timeline_event.created_at,
          links: timeline_event.links
        }
      end
    end
  end
end
