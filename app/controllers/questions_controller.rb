class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :community, except: %i[show edit update]

  layout 'community'

  def show
    @question = authorize(Question.find(params[:id]))
    raise_not_found if @question.blank?
    @answer = Answer.new(question: @question, user: current_user)
  end

  def new
    @question = authorize(Question.new(community: @community))
    raise_not_found if @question.blank?
  end

  def edit
    @question = authorize(Question.find(params[:id]))
    raise_not_found if @question.blank?
  end

  def create
    question = authorize(Question.new(community: @community, user: current_user))
    form = Questions::CreateOrUpdateForm.new(question)
    if form.validate(question_params)
      new_question = form.save
      redirect_to question_path(new_question)
    else
      raise form.errors.full_messages.join(', ')
    end
  end

  def update
    question = authorize(Question.find(params[:id]))
    form = Questions::CreateOrUpdateForm.new(question)
    if form.validate(question_params)
      form.save
      redirect_to question_path(question)
    else
      raise form.errors.full_messages.join(', ')
    end
  end

  private

  def community
    @community = Community.find(params[:community_id])
  end

  def question_params
    params.require(:question).permit(:title, :description)
  end
end
