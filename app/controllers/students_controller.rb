class StudentsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /home/
  def home
    @user = current_user
  end
end
