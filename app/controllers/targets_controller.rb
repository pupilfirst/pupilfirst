class TargetsController < ApplicationController
  before_action :authenticate_founder!, except: :select2_search
  before_action :authenticate_user!, only: :select2_search

  # GET /targets/select2_search
  def select2_search
    raise_not_found if true_user.admin_user.blank?
    render json: Targets::Select2SearchService.search_for_target(params[:q])
  end

  # GET /targets/:id/prerequisite_targets
  def prerequisite_targets
    target = authorize(Target.find(params[:id]))

    prerequisite_targets = target.prerequisite_targets.each_with_object({}) do |p_target, hash|
      status = Targets::StatusService.new(p_target, current_founder).status
      next if status == Targets::StatusService::STATUS_PASSED

      hash[p_target.id] = p_target.title
    end

    render json: prerequisite_targets
  end

  # GET /targets/:id/startup_feedback
  def startup_feedback
    target = authorize(Target.find(params[:id]))

    latest_feedback = Targets::FeedbackService.new(target, current_founder).feedback_for_latest_event

    startup_feedback = latest_feedback.each_with_object({}) do |feedback, hash|
      hash[feedback.id] = feedback.feedback
    end

    render json: startup_feedback
  end

  # GET /targets/:id/details
  def details
    target = authorize(Target.find(params[:id]))

    render json: Targets::OverlayDetailsService.new(target, current_founder).all_details
  end

  # POST /targets/:id/auto_verify
  def auto_verify
    target = authorize(Target.find(params[:id]))
    Targets::AutoVerificationService.new(target, current_founder).auto_verify
    head :ok
  end
end
