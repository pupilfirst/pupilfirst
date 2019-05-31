class CommunitiesController < ApplicationController
  layout 'student'

  # GET /communities/:id
  def show
    @community = authorize(Community.find(params[:id]))
    @search = params[:search]
    @questions = scoped_questions.where.not(archived: true).includes(%i[creator answers])
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
    if params[:target_id].present? && target.present?
      target.questions.where(community: @community)
    else
      @community.questions
    end
  end

  def target
    @target ||= begin
      t = Target.find_by(id: params[:target_id])

      # Only return the target if the target is in a course that is linked to this community.
      @community.courses.where(id: t.course).exists? ? t : nil
    end
  end
end
