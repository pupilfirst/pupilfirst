class CommunitiesController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /communities/:id
  def show
    @community = authorize(Community.find(params[:id]))
    target
  end

  # GET /community/:community_id/new_topic
  def new_topic
    @community = authorize(Community.find(params[:id]))
    target
  end

  private

  def page
    @page ||= begin
      page = params[:page].to_i
      page.zero? ? 1 : page
    end
  end

  def target
    return unless @community.target_linkable?

    @target ||= if params[:target_id].present?
      t = Target.find_by(id: params[:target_id])

      # Only return the target if the target is in a course that is linked to this community.
      @community.courses.exists?(id: t&.course) ? t : nil
    end
  end
end
