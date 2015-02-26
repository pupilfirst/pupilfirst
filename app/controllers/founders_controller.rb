class FoundersController < ApplicationController

  def index
    @startup = Startup.find params[:startup_id]
  end

  def invite
    @current_user = current_user
    @user = User.find_by_email(params[:email])
    if params[:email].present?
      if @user.nil?
        fullname = params[:email].split("@")[0]
        session[:current_username] = current_user.fullname
        @user = User.invite!({
          email: params[:email],
          startup_id: current_user.startup.id, is_founder: true, startup_link_verifier_id: current_user.id,
          inviter_name: current_user.fullname})
        @user.save!(validate: false)
        flash[:notice] = 'Email invite sent!'
      elsif @user.startup
        flash[:alert] = 'This user is associated with another startup.'
      else
        UserMailer.request_to_be_a_founder(@user, current_user.startup, current_user).deliver_later
        flash[:notice] = 'An email has been sent to the user to join your startup as a founder.'
      end
    else
      flash[:alert] = 'Please enter a valid email'
    end
    redirect_to action: :index
  end
end
