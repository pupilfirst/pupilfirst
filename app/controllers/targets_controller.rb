class TargetsController < ApplicationController
  # GET /targets/:id/download_rubric
  def download_rubric
    authorize :target
    redirect_to Target.find(params[:id]).rubric_url
  end

  # GET /targets/select2_search
  def select2_search
    raise_not_found unless true_user.admin_user.present?
    render json: Targets::Select2SearchService.search_for_target(params[:q])
  end

  # GET /targets/:id/prerequisite_targets
  def prerequisite_targets
    authorize :target
    target = Target.find(params[:id])
    prerequisite_targets = target.prerequisite_targets.each_with_object({}) do |p_target, hash|
      hash[p_target.id] = p_target.title
    end
    render json: prerequisite_targets
  end
end
