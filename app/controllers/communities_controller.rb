class CommunitiesController < ApplicationController
  layout 'community'

  # GET /communities/:id
  def show
    @community = authorize(Community.find(params[:id]))
    @questions = Kaminari.paginate_array(@community.questions.includes(%i[user answers])
      .order("answers.updated_at DESC NULLs FIRST")).page(params[:page]).per(10)

    raise_not_found if @community.blank?
  end
end
