class UsersController < ApplicationController

	before_filter do
		self.class.layout false if params[:partial].present?
	end

  def show
  end

  def edit
  end

  def new
  end

  def invite
  end

  def send_invite
  	@user = User.find_by_email(params[:user][:email]) rescue nil
		if @user.try(:startup).nil?
			@user = User.invite!(invite_params)
			@user.startup = Startup.find(session[:startup_id])
			@user.save!
		else
			p "*"*80
			@user.errors[:exist] = "this user is associated with other startup"
		end
  end

  def create
  end

  private

  def invite_params
  	params.require(:user).permit(:email, :fullname)
  end

  def user_params
      params.require(:user).permit(:fullname, :username, :email)
  end
end
