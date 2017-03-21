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
      list_service = TimelineEventTypes::ListService.new(@startup)

      @react_data = {
        currentLevel: @startup.level.number,
        requestedRestartLevel: @startup.requested_restart_level&.number,
        levels: dashboard_data_service.levels,
        chores: dashboard_data_service.chores,
        sessions: dashboard_data_service.sessions,
        sessionTags: dashboard_data_service.session_tags,
        timelineEventTypes: list_service.list,
        allowFacebookShare: current_founder.facebook_token_available?
      }

      @restart_form = Founders::StartupRestartForm.new(OpenStruct.new) if @startup.restartable_levels.present?

      @tour = tour_dashboard?
    end

    # POST /founder/startup_restart
    def startup_restart
      startup = current_founder.startup
      raise_not_found unless startup.restartable_levels.present?

      @restart_form = Founders::StartupRestartForm.new(OpenStruct.new)

      if @restart_form.validate(startup_restart_params)
        level = Level.find(startup_restart_params.fetch(:level_id))
        reason = startup_restart_params.fetch(:reason)
        Startups::RestartService.new(current_founder).request_restart(level, reason)

        flash[:success] = 'Your request for restart has been submitted successfully!'
      else
        flash[:error] = 'Something went wrong. Please try again!'
      end

      redirect_to dashboard_founder_path
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

    def startup_restart_params
      params.require(:founders_startup_restart).permit(:level_id, :reason)
    end
  end
end
