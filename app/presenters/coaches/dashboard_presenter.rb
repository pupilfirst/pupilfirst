module Coaches
  class DashboardPresenter < ApplicationPresenter
    def react_props
      {
        coach: { name: current_coach.name, id: current_coach.id, imageUrl: current_coach.image_url },
        startups: startups,
        timelineEvents: timeline_events,
        authenticityToken: view.form_authenticity_token,
        emptyIconUrl: view.image_url('coaches/dashboard/empty_icon.svg'),
        needsImprovementIconUrl: view.image_url('coaches/dashboard/needs-improvement-icon.svg'),
        notAcceptedIconUrl: view.image_url('coaches/dashboard/not-accepted-icon.svg'),
        verifiedIconUrl: view.image_url('coaches/dashboard/verified-icon.svg')
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

    # rubocop:disable Metrics/AbcSize
    def timeline_events
      TimelineEvent.not_auto_verified.where(startup: current_coach.startups).includes(:founder, :startup, :timeline_event_files, :timeline_event_type, :startup_feedback).order(:created_at).map do |timeline_event|
        {
          id: timeline_event.id,
          title: title(timeline_event),
          description: timeline_event.description,
          eventOn: timeline_event.event_on,
          status: timeline_event.status,
          startupId: timeline_event.startup_id,
          startupName: timeline_event.startup.product_name,
          founderId: timeline_event.founder_id,
          founderName: timeline_event.founder.name,
          links: timeline_event.links,
          files: timeline_event.timeline_event_files.map { |file| { title: file.title, id: file.id } },
          image: timeline_event.image? ? timeline_event.image.url : nil,
          grade: timeline_event.overall_grade_from_score,
          latestFeedback: timeline_event.startup_feedback&.last&.feedback
        }
      end
    end
    # rubocop:enable Metrics/AbcSize

    def logo_url(startup)
      startup.logo_url || identicon_logo(startup)
    end

    def identicon_logo(startup)
      base64_logo = Startups::IdenticonLogoService.new(startup).base64_svg
      "data:image/svg+xml;base64,#{base64_logo}"
    end

    def title(timeline_event)
      timeline_event.target.level.short_name + ' | ' + timeline_event.target.title
    end
  end
end
