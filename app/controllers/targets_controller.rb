class TargetsController < ApplicationController
  # GET /targets/:id/download_rubric
  def download_rubric
    authorize :target
    target = Target.find(params[:id])

    if target.performance_criteria.exists?
      pdf = Targets::RubricPdf.new(target).build
      send_data pdf.render, type: 'application/pdf', filename: 'target_rubric.pdf', disposition: 'inline'
    else
      redirect_to target.rubric_url
    end
  end

  # GET /targets/select2_search
  def select2_search
    raise_not_found if true_user.admin_user.blank?
    render json: Targets::Select2SearchService.search_for_target(params[:q])
  end

  # GET /targets/:id/prerequisite_targets
  def prerequisite_targets
    authorize :target
    target = Target.find(params[:id])
    prerequisite_targets = target.prerequisite_targets.each_with_object({}) do |p_target, hash|
      status = Targets::StatusService.new(p_target, current_founder).status
      next if status.in? [Target::STATUS_COMPLETE, Target::STATUS_NEEDS_IMPROVEMENT]
      hash[p_target.id] = p_target.title
    end
    render json: prerequisite_targets
  end

  # GET /targets/:id/startup_feedback
  def startup_feedback
    authorize :target
    target = Target.find(params[:id])
    latest_feedback = Targets::FeedbackService.new(target, current_founder).feedback_for_latest_event

    startup_feedback = latest_feedback.each_with_object({}) do |feedback, hash|
      hash[feedback.id] = feedback.feedback
    end

    render json: startup_feedback
  end

  # GET /targets/:id/founder_statuses
  def founder_statuses
    authorize :target

    target = Target.find(params[:id])
    render json: Targets::OverlayDetailsService.new(target, current_founder).founder_statuses
  end

  # GET /targets/:id/details
  def details
    authorize :target

    target = Target.find(params[:id])
    render json: Targets::OverlayDetailsService.new(target, current_founder).all_details
  end
end
