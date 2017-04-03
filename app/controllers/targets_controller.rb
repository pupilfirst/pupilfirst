class TargetsController < ApplicationController
  before_action :restrict_to_founder

  # GET /targets/:id/download_rubric
  def download_rubric
    redirect_to target.rubric_url
  end

  private

  def target
    @target ||= Target.find(params[:id])
  end

  def restrict_to_founder
    raise_not_found unless current_founder.present?
  end
end
