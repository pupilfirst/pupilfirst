class StudentsController < ApplicationController
  before_action :authenticate_user!
  layout 'community'

  # GET /home/
  def home
    @user = current_user
  end
end
