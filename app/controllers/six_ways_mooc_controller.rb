class SixWaysMoocController < ApplicationController
  before_action :authorize_student

  # the landing page for sixways
  def index
    # something
  end

  protected

  def current_mooc_student
    @current_mooc_student ||= begin
      return nil unless current_user.present?
      MoocStudent.where(user: current_user).first_or_create
    end
  end

  private

  def authorize_student
    request_authentication if current_mooc_student.blank?
  end

  def request_authentication
    redirect_to user_sessions_new_path(token: params[:token], referer: request.url)
  end
end
