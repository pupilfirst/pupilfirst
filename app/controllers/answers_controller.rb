class AnswersController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def versions
    @answer = authorize(Answer.live.find(params[:id]))
  end
end
