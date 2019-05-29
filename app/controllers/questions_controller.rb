class QuestionsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def show
    @question = authorize(Question.find(params[:id]))
    raise_not_found if @question.blank?
  end

  def versions
    @question = authorize(Question.find(params[:id]))

    raise_not_found if @question.blank?
  end
end
