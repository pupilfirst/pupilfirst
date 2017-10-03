class TechHuntController < ApplicationController
  layout false

  # GET /hunt
  def index
    redirect_to tech_hunt_question_path if current_player.present?
  end

  # GET /hunt/q
  def question
    if current_player.blank?
      redirect_to tech_hunt_path
      return
    end

    @stage = current_player.stage
  end
end
