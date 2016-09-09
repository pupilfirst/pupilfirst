class CollegesController < ApplicationController
  # GET /colleges
  def index
    if params[:q].blank?
      render json: []
      return
    end

    render json: Select2Presenter.search_for_college(params[:q])
  end
end
