class FoundersController < ApplicationController

  def index
    @startup = Startup.find params[:startup_id]
  end

  def invite
    @user = User.find_by_email(params[:email])
    if @user.nil?
      fullname = params[:email].split("@")[0]
      @user = User.invite!({
        fullname: fullname, email: params[:email],
        startup_id: current_user.startup.id, is_founder: true, startup_link_verifier_id: current_user.id})
      @user.save!
      flash[:notice] = "Email invite sent!"
    elsif @user.startup == current_user.startup
      if @user.is_founder?
        flash[:notice] = "This user is already a founder in your startup"
      else
        current_user.startup.founders << @user
        UserMailer.assigned_as_founder(@user, current_user.startup).deliver
      end
    elsif @user.startup.nil?
      UserMailer.request_to_be_a_founder(@user, current_user.startup, current_user).deliver
      flash[:notice] = "An email has been sent to the user to join your startup as a founder."
    else
      flash[:alert] = "This user is associated with another startup."
    end
    index and render :index
  end
end
