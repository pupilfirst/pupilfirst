module Founders
  class DashboardController < ApplicationController
    before_action :authenticate_founder!
    before_action :skip_container

    layout 'application_v2'

    # GET /founder/dashboard
    def dashboard
      @startup = current_founder.startup&.decorate
      @batch = @startup&.batch&.decorate

      # founders without proper startups will not have dashboards
      raise_not_found unless @startup.present? && @batch.present?

      dashboard_data_service = Founders::DashboardDataService.new(current_founder)

      @react_data = {
        targetGroups: dashboard_data_service.target_groups,
        chores: dashboard_data_service.chores,
        sessions: dashboard_data_service.sessions
      }

      @tour = tour_dashboard?
    end

    # GET /founder/performance_stats
    def performance_stats
      @startup = current_founder.startup&.decorate
      @batch = @startup&.batch&.decorate

      render layout: false
    end

    private

    def skip_container
      @skip_container = true
    end

    # Shall we take the founder on a tour of the dashboard?
    def tour_dashboard?
      return false if current_founder.blank?
      return false if current_founder.startup != @startup.model
      (current_founder.tour_dashboard? || params[:tour].present?)
    end
  end
end
