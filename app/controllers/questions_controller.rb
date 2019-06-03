class QuestionsController < ApplicationController
  before_action :authenticate_user!

  layout 'student'

  # GET /community/:community_id/questions/new
  def new
    @community = Community.find(params[:community_id])
    @target = find_target(params[:target_id])
  end

  def show
    @question = authorize(Question.live.find(params[:id]))
  end

  def versions
    @question = authorize(Question.live.find(params[:id]))
  end

  private

  def find_target(target_id)
    # Community should have the target_linkable flag set.
    return unless @community.target_linkable?

    target = Target.find_by(id: target_id)

    # Only return the target if the target is in a course that is linked to this community.
    return if @community.courses.where(id: target&.course).empty?

    target
  end
end
