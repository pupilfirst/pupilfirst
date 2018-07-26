module Coaches
  class DashboardPresenter < ApplicationPresenter
    def react_props
      {
        coach: { name: current_coach.name, id: current_coach.id, imageUrl: current_coach.image_url },
        startups: startups,
        timelineEvents: timeline_events,
        authenticityToken: view.form_authenticity_token
      }
    end

    private

    def current_coach
      @current_coach ||= view.current_coach
    end

    def startups
      @startups ||= begin
        current_coach.startups.includes(:level).map do |startup|
          {
            name: startup.product_name,
            id: startup.id,
            levelNumber: startup.level.number,
            levelName: startup.level.name,
            logoUrl: logo_url(startup)
          }
        end
      end
    end

    def timeline_events
      TimelineEvent.not_auto_verified.where(startup: current_coach.startups).includes(:founder, :startup, :timeline_event_files, :timeline_event_type).map do |timeline_event|
        {
          id: timeline_event.id,
          title: timeline_event.target&.title || timeline_event.title,
          description: timeline_event.description,
          eventOn: timeline_event.event_on,
          status: timeline_event.status,
          startupId: timeline_event.startup_id,
          startupName: timeline_event.startup.product_name,
          founderId: timeline_event.founder_id,
          founderName: timeline_event.founder.name,
          submittedAt: timeline_event.created_at,
          links: timeline_event.links,
          files: timeline_event.timeline_event_files.map { |file| { title: file.title, id: file.id } },
          grade: timeline_event.overall_grade_from_score
        }
      end
    end

    def logo_url(startup)
      startup.logo_url || identicon_logo(startup)
    end

    def identicon_logo(startup)
      base64_logo = Startups::IdenticonLogoService.new(startup).base64_svg
      "data:image/svg+xml;base64,#{base64_logo}"
    end
  end
end
