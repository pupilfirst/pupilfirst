class TargetsController < ApplicationController
  # GET /targets/:id/download_rubric
  def download_rubric
    authorize :target
    redirect_to Target.find(params[:id]).rubric_url
  end

  # GET /targets/select2_search
  def select2_search
    raise_not_found unless true_user.admin_user?
    render json: Targets::Select2SearchService.search_for_target(params[:q])
  end
end
