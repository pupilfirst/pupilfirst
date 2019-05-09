class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :community, except: %i[show]

  layout 'community'

  def show
    @question = authorize(Question.find(params[:id]))
    raise_not_found if @question.blank?
  end

  def new
    @question = authorize(Question.new(community: @community))
    raise_not_found if @question.blank?
  end

  private

  def community
    @community = Community.find(params[:community_id])
  end
end
