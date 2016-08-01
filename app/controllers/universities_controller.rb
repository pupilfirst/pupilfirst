class UniversitiesController < ApplicationController
  # GET /universities
  def index
    if params[:q].blank?
      render json: []
      return
    end

    render json: University.select2_search(params[:q])
  end
end
