class UsersController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /home/
  def home
    @user = authorize(current_user)
  end
end
