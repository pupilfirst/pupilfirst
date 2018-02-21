module Founders
  class DashboardController < ApplicationController
    before_action :authenticate_founder!
    before_action :skip_container
    before_action :require_active_subscription, if: :startup_is_admitted

    # GET /founder/dashboard, GET /student/dashboard
    def dashboard
      # TODO: Add Pundit authorization.

      # Founders without proper startups will not have dashboards.
      raise_not_found if current_startup.blank?
    end

    # GET /founder/dashboard/targets/:id(/:slug), GET /student/dashboard/targets/:id(/:slug)
    def target_overlay
      # TODO: Add Pundit authorization

      dashboard

      @target = Target.find_by(id: params[:id])
      raise_not_found if @target.blank?

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
