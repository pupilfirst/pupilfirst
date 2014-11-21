class MentoringController < ApplicationController
  before_filter :authenticate_user!, except: %w(index sign_up sign_up_form)
  before_filter :redirect_step1, only: %w(new_step1 register)
  before_filter :redirect_step2, only: %w(new_step2 register_2)

  # GET /mentoring
  def index
  end

  # GET /mentoring/register
  def new_step1
    @mentor = current_user.build_mentor
  end

  # POST /mentoring/register
  def register
    @mentor = current_user.build_mentor
    # @mentor = Mentor.new(mentor_params)

    if @mentor.update(mentor_params)
      redirect_to mentoring_register_2_url
    else
      render 'new_step1'
    end
  end

  # GET /mentoring/register_2
  def new_step2
    @mentor = current_user.mentor
  end

  # POST /mentoring/register_2
  def register_2
    @mentor = current_user.mentor
  end

  # GET /mentoring/sign_up
  def sign_up_form
    @user = User.new
  end

  # POST /mentoring/sign_up
  def sign_up
    @user = User.new user_params

    if @user.save
      flash[:notice] = 'Your SV account has been created. Please login with your SV ID and password.'
      redirect_to mentoring_url
    else
      render :sign_up_form
    end
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :email, :password, :password_confirmation)
  end

  def mentor_params
    params.require(:mentor).permit({ user_attributes: [:id, :fullname, :title] }, :company_id,
      :company_level, :cost_to_company, :time_donate_percentage, :days_available, :time_available
    )
  end

  # Prevent repeat of registration step.
  def redirect_step1
    if current_user.mentor.present?
      if current_user.mentor.skills.present?
        redirect_to mentoring_url
      else
        redirect_to mentoring_register_2_url
      end
    end
  end

  # Prevent repeat of registration step.
  def redirect_step2
    if current_user.mentor.present?
      redirect_to mentoring_url if current_user.mentor.skills.present?
    else
      redirect_to mentoring_register_url
    end
  end
end
