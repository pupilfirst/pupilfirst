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

  # POST /hunt/sign_up
  def sign_up
    # TODO: Handle missing/ill-formed params[:player]
    @form = TechHuntSignUpForm.new(Reform::OpenForm.new)
    if @form.validate(params[:player])
      @form.save
      render json: { success: true, next_step: 'Visit your inbox' }
    else
      render json: { success: false, errors: @form.errors }
    end
  end
end
