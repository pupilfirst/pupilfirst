class TechHuntController < ApplicationController
  before_action :go_fullscreen
  # skip_after_action :intercom_rails_auto_include

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

    # Stub the hunt at level 5 for now.
    @hide_answer_box = true if @stage == 5
  end

  # POST /hunt/answer_submit
  def answer_submit
    raise_not_found if current_player.blank?

    @stage = current_player.stage

    answer = params.dig(:answer, :answer)
    if answer&.downcase == HuntAnswer.find_by(stage: @stage).answer.downcase
      current_player.update!(stage: @stage + 1, attempts: current_player.attempts + 1)
      redirect_to tech_hunt_question_path
      return
    else
      current_player.update!(attempts: current_player.attempts + 1)
      @error = true
      render 'question'
    end
  end

  private

  def go_fullscreen
    @skip_container = true
    @hide_layout_header = true
    @hide_layout_footer = true
  end
end
