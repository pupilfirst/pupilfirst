module Founders
  class DashboardController < ApplicationController
    before_action :authenticate_founder!
    before_action :skip_container

    layout 'application_v2'

    # GET /founder/dashboard
    def dashboard
      @startup = current_founder.startup&.decorate

      # founders without proper startups will not have dashboards
      raise_not_found unless @startup.present?

      load_react_data

      @restart_form = Founders::StartupRestartForm.new(OpenStruct.new) if @startup.restartable_levels.present?

      @tour = tour_dashboard?
    end

    # POST /founder/startup_restart
    def startup_restart
      startup = current_founder.startup
      raise_not_found if startup.restartable_levels.blank?

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

    # POST /founder/startup/level_up
    def level_up
      startup = current_founder.startup
      raise_not_found unless Startups::LevelUpEligibilityService.new(startup, current_founder).eligible?
      Startups::LevelUpService.new(startup).execute
      redirect_back(fallback_location: dashboard_founder_path)
    end

    # GET /founder/dashboard/founder_target_statuses/:target_id
    def founder_target_statuses
      target = Target.find(params[:target_id])
      founder_statuses = current_founder.startup.founders.not_exited.each_with_object([]) do |founder, statuses|
        statuses << { founder.id => Targets::StatusService.new(target, founder).status }
        # statuses[founder.id] = Targets::StatusService.new(target, founder).status
      end

      render json: founder_statuses
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

    def founder_details
      @startup.founders.not_exited.each_with_object([]) do |founder, array|
        array << {
          founderId: founder.id,
          founderName: founder.name,
          avatar: avatar(founder.name, founder: founder)
        }
      end
    end

    def dashboard_data_service
      @dashboard_data_service ||= Founders::DashboardDataService.new(current_founder)
    end

    def list_service
      @list_service ||= TimelineEventTypes::ListService.new(@startup)
    end

    def load_react_data
      @react_data = {
        currentLevel: @startup.level.number,
        requestedRestartLevel: @startup.requested_restart_level&.number,
        levels: dashboard_data_service.levels,
        chores: dashboard_data_service.chores,
        sessions: dashboard_data_service.sessions,
        sessionTags: dashboard_data_service.session_tags,
        timelineEventTypes: list_service.list,
        facebookShareEligibility: current_founder.facebook_share_eligibility,
        levelUpEligibility: Startups::LevelUpEligibilityService.new(@startup, current_founder).eligibility,
        maxLevelNumber: Level.maximum.number,
        founderDetails: founder_details
      }
    end
  end
end
