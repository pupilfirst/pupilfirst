class CommunitiesController < ApplicationController
  layout 'school'

  # GET /communities/:id
  def show
    @community = authorize(Community.find(params[:id]))
    raise_not_found if @community.blank?
  end
end
