module Coaches
  class DashboardPresenter < ApplicationPresenter
    def react_props
      {
        coach: { name: current_coach.name, id: current_coach.id, imageUrl: current_coach.image_url },
        startups: startups,
        timelineEvents: FacultyModule::ReviewableTimelineEventsService.new(current_coach).timeline_events(view.current_school),
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

    def logo_url(startup)
      startup.logo_url || identicon_logo(startup)
    end

    def identicon_logo(startup)
      base64_logo = Startups::IdenticonLogoService.new(startup).base64_svg
      "data:image/svg+xml;base64,#{base64_logo}"
    end
  end
end
