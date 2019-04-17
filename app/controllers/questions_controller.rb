class QuestionsController < ApplicationController
  layout 'school'

  def show
    @question = authorize(Question.find(params[:id]))
    raise_not_found if @question.blank?
  end
end
