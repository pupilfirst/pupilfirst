class MentoringController < ApplicationController
  before_filter :authenticate_user!, except: %w(index sign_up sign_up_form)

  # GET /mentoring
  def index; end

  # GET /mentoring/register
  def new
    @mentor = Mentor.new user: current_user
  end

  # POST /mentoring/register
  def register

  end

  # GET /mentoring/sign_up
  def sign_up_form
    @user = User.new
  end

  # POST /mentoring/sign_up
  def sign_up
    @user = User.new mentor_params

    if @user.save
      flash[:notice] = 'Your SV account has been created. Please login with your SV ID and password.'
      redirect_to mentoring_url
    else
      render :sign_up_form
    end
  end

  private

  def mentor_params
    params.require(:user).permit(:fullname, :email, :password, :password_confirmation)
  end
end
