module Founders
  module Dashboard
    class DashboardPresenter < ApplicationPresenter
      def initialize(view_context, overlay_target: nil)
        @overlay_target = overlay_target
        super(view_context)
      end

      def react_props
        dashboard_data_service.props.merge(
          currentLevel: current_startup.level.slice(:id, :name, :number),
          timelineEventTypes: list_service.list,
          facebookShareEligibility: current_founder.facebook_share_eligibility,
          levelUpEligibility: Startups::LevelUpEligibilityService.new(current_startup, current_founder).eligibility,
          maxLevelNumber: Level.maximum.number,
          founderDetails: founder_details,
          authenticityToken: view.form_authenticity_token,
          iconPaths: icon_paths,
          testMode: Rails.env.test?,
          initialTargetId: @overlay_target&.id
        )
      end

      def tour_dashboard?
        return false if current_startup.level_zero?
        (current_founder.tour_dashboard? || view.params[:tour].present?)
      end

      private

      def current_startup
        view.current_startup
      end

      def current_founder
        view.current_founder
      end

      def icon_paths
        {
          personalTodo: view.image_path('founders/dashboard/target-type-icon-personal-todo.svg'),
          noResults: view.image_path('founders/dashboard/target-list-icon-no-results.svg'),
          teamTodo: view.image_path('founders/dashboard/target-type-icon-team-todo.svg'),
          attendSession: view.image_path('founders/dashboard/target-type-icon-attend-session.svg'),
          targetDescription: view.image_path('founders/dashboard/target-overlay-description-icon.svg'),
          videoEmbed: view.image_path('founders/dashboard/target-overlay-video-icon.svg'),
          slideshowEmbed: view.image_path('founders/dashboard/target-overlay-slide-icon.svg'),
          resourceLinks: view.image_path('founders/dashboard/target-overlay-resources-icon.svg'),
          completionInstruction: view.image_path('founders/dashboard/target-overlay-instruction-icon.svg'),
          backButton: view.image_path('founders/dashboard/target-overlay-back-icon.svg')
        }
      end

      def founder_details
        current_startup.founders.not_exited.each_with_object([]) do |founder, array|
          array << {
            founderId: founder.id,
            founderName: founder.name,
            avatar: view.avatar(founder.name, founder: founder)
          }
        end
      end

      def dashboard_data_service
        @dashboard_data_service ||= Founders::DashboardDataService.new(current_founder)
      end

      def list_service
        @list_service ||= TimelineEventTypes::ListService.new(current_startup)
      end
    end
  end
end
