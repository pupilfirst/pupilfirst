class TargetsController < ApplicationController
  before_action :restrict_to_founder, except: :select2_search

  # GET /targets/:id/download_rubric
  def download_rubric
    redirect_to target.rubric_url
  end

  # GET /targets/select2_search
  def select2_search
    # TODO: Replace with Pundit authorization when available on master
    raise_not_found unless current_user&.admin_user

    render json: Targets::Select2SearchService.search_for_target(params[:q])
  end

  private

  def target
    @target ||= Target.find(params[:id])
  end

  def restrict_to_founder
    raise_not_found unless current_founder.present?
  end
end
