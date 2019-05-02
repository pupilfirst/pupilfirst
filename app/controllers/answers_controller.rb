class AnswersController < ApplicationController
  before_action :authenticate_user!

  layout 'community'

  def edit
    @answer = authorize(Answer.find(params[:id]))
    @question = @answer.question
    raise_not_found if @answer.blank?
  end

  def create
    @question = Question.find(params[:question_id])
    answer = authorize(Answer.new(question: @question, user: current_user))
    form = Answers::CreateOrUpdateForm.new(answer)
    if form.validate(answer_params)
      form.save
      redirect_to community_question_path(@question.community_id, @question.id)
    else
      raise form.errors.full_messages.join(', ')
    end
  end

  def update
    answer = authorize(Answer.find(params[:id]))
    question = answer.question
    form = Answers::CreateOrUpdateForm.new(answer)
    if form.validate(answer_params)
      form.save
      redirect_to community_question_path(question.community_id, question.id)
    else
      raise form.errors.full_messages.join(', ')
    end
  end

  def destroy
    @answer = authorize(Answer.find(params[:id]))
    question = @answer.question
    @answer.answer_likes.delete_all
    @answer.delete
    redirect_to community_question_path(question.community_id, question.id)
  end

  private

  def answer_params
    params.require(:answer).permit(:description)
  end
end
