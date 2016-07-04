class SixWaysMoocController < ApplicationController
  before_action :authorize_student

  # the landing page for sixways
  def index
    # something
  end

  protected

  def current_mooc_student
    @current_mooc_student ||= begin
      return false unless current_user.present?
      MoocStudent.where(user: current_user).first
    end
  end

  private

  def authorize_student
    binding.pry
    current_mooc_student.present? ? return : request_authentication
  end

  def request_authentication
    redirect_to user_authentication_path(referrer: request.url, token: params[:token])
  end

  def check_for_token
    params[:token].present? ? validate_token : request_identification
  end

  def validate_token
    if token_valid?
      find_or_create_student
      save_token
    else
      request_identification
    end
  end

  def token_valid?
    @user = User.find_by(login_token: params[:token])
  end

  def save_token
    cookies[:login_token] = { value: @user.login_token, expires: 2.months.from_now }
  end

  def request_identification
    session[:referer] = request.url
    redirect_to user_identify_path
  end

  def find_or_create_student
    MoocStudent.where(user: @user).first_or_create
  end
end
