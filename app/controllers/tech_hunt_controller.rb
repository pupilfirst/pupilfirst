class TechHuntController < ApplicationController
  before_action :go_fullscreen

  # GET /hunt
  def index
    if current_player.present?
      if current_player.stage.positive?
        redirect_to tech_hunt_question_path
      else
        @invitation_pending = true
      end
    else
      @form = TechHuntSignUpForm.new(Player.new)
    end
  end

  # POST /hunt/register
  def register
    @form = TechHuntSignUpForm.new(Player.new)
    if @form.validate(params[:tech_hunt_sign_up])
      @form.save
    else
      render 'index'
    end
  end

  # GET /hunt/q
  def question
    if current_player.blank?
      redirect_to tech_hunt_path
      return
    end

    @stage = current_player.stage
  end

  # POST /hunt/answer_submit
  def answer_submit
    raise_not_found if current_player.blank?

    @stage = current_player.stage

    answer = params.dig(:answer, :answer)
    if answer&.downcase == HuntAnswer.find_by(stage: @stage).answer.downcase
      current_player.update!(stage: @stage + 1)
      redirect_to tech_hunt_question_path
      return
    else
      @error = true
      render 'question'
    end
  end

  # # POST /hunt/sign_up
  # def sign_up
  #   # TODO: Handle missing/ill-formed params[:player]
  #
  #   @form = TechHuntSignUpForm.new(Reform::OpenForm.new)
  #   if @form.validate(player_params)
  #     @form.save
  #     render json: { success: true, next_step: 'Visit your inbox' }
  #   else
  #     render json: { success: false, errors: @form.errors }
  #   end
  # end

  private

  def go_fullscreen
    @skip_container = true
    @hide_layout_header = true
    @hide_layout_footer = true
  end
end
