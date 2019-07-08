class QuestionsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def show
    @question = authorize(Question.live.find(params[:id]))
  end

  def versions
    @question = authorize(Question.live.find(params[:id]))
  end
end
