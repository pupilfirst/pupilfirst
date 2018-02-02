module Founders
  class DashboardController < ApplicationController
    before_action :authenticate_founder!
    before_action :skip_container
    before_action :require_active_subscription, if: :startup_is_admitted

    # GET /founder/dashboard
    def dashboard
      @startup = current_founder.startup&.decorate

      # founders without proper startups will not have dashboards
      raise_not_found if @startup.blank?

      load_react_data

      @tour = tour_dashboard?
    end

    # POST /founder/startup_restart
    def startup_restart
      startup = current_founder.startup
      raise_not_found if startup.restartable_levels.blank?

      if @restart_form.validate(startup_restart_params)
        level = Level.find(startup_restart_params.fetch(:level_id))
        reason = startup_restart_params.fetch(:reason)
        Startups::RestartService.new(current_founder).request_restart(level, reason)

        flash[:success] = 'Your request for a pivot has been submitted successfully!'
      else
        flash[:error] = 'Something went wrong. Please try again!'
      end

      redirect_to dashboard_founder_path(from: 'startup_restart')
    end

    # GET /founder/dashboard/targets/:id(/:slug)
    def target_overlay
      # TODO: Add Pundit authorization

      @target = Target.find_by(id: params[:id])
      raise_not_found if @target.blank?

      dashboard
      set_initial_target
      render 'dashboard'
    end

    private

    def startup_is_admitted
      return if current_founder.blank?
      current_startup.present? && !current_startup.level_zero?
    end

    def skip_container
      @skip_container = true
    end

    # Shall we take the founder on a tour of the dashboard?
    def tour_dashboard?
      return false if current_startup.level_zero?
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
        sessions: dashboard_data_service.sessions,
        sessionTags: dashboard_data_service.session_tags,
        timelineEventTypes: list_service.list,
        facebookShareEligibility: current_founder.facebook_share_eligibility,
        levelUpEligibility: Startups::LevelUpEligibilityService.new(@startup, current_founder).eligibility,
        maxLevelNumber: Level.maximum.number,
        founderDetails: founder_details,
        programLevels: program_levels
      }
    end

    def program_levels
      Level.all.order(:number).each_with_object({}) do |level, hash|
        hash[level.number] = level.name
      end
    end

    def set_initial_target
      @react_data[:initialTargetId] = @target.id
      @react_data[:initialTargetType] = @target.target_type
    end

    # def append_founder_statuses
    #   return unless @target.founder_role?
    #
    #   founders = current_founder.startup.founders.not_exited
    #   @react_data[:initialTargetFounderStatuses] = founders.each_with_object([]) do |founder, statuses|
    #     statuses << { founder.id => Targets::StatusService.new(@target, founder).status }
    #   end
    # end
    #
    # def append_startup_feedback
    #   @react_data[:initialTargetLatestFeedback] = Targets::FeedbackService.new(@target, current_founder).latest_feedback_details
    # end
  end
end
