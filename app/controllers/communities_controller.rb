class CommunitiesController < ApplicationController
  layout 'community'

  # GET /communities/:id
  def show
    @community = authorize(Community.find(params[:id]))
    @search = params[:search]
    @questions = scoped_questions.includes(%i[user answers])
      .order("last_activity_at DESC NULLs FIRST").page(page).per(10)

    raise_not_found if @community.blank?
  end

  private

  def page
    @page ||= begin
      page = params[:page].to_i
      page.zero? ? 1 : page
    end
  end

  def scoped_questions
    if params[:search].present?
      filtered_question.where('title ILIKE ?', "%#{@search.downcase}%")
    else
      filtered_question
    end
  end

  def filtered_question
    if params[:target_id].present?
      @community.questions.where(target_id: params[:target_id])
    else
      @community.questions
    end
  end
end
