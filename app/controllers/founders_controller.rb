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
        startup_id: current_user.startup.id, is_founder: true})
      @user.save!
      flash[:notice] = "Email invite sent!"
    elsif @user.startup
      flash[:alert] = "User with this email already exist."
    else
      flash[:alert] = "This user is associated with other startup."
    end
    # SENDEMAIL
    index and render :index
  end
end
