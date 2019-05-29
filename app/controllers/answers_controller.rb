class AnswersController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def versions
    @answer = authorize(Answer.find(params[:id]))

    raise_not_found if @answer.blank?
  end
end
