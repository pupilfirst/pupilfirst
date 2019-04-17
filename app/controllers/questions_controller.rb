class QuestionsController < ApplicationController
  layout 'community'

  def show
    @question = authorize(Question.find(params[:id]))
    raise_not_found if @question.blank?
  end
end
