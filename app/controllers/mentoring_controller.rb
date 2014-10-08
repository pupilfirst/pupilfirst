class MentoringController < ApplicationController
  before_filter :authenticate_user!

  # GET /mentoring
  def index

  end

  # GET /mentoring/register
  def new
    @mentor = Mentor.new user: current_user
  end

  # POST /mentoring/register
  def register

  end
end
