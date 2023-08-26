class CohortsController < ApplicationController
  before_action :authenticate_user!
  layout "student_course"

  # GET /cohorts/:id
  def show
    @cohort = authorize current_school.cohorts.find(params[:id])
    @course = @cohort.course
    @presenter = Cohorts::StudentsPresenter.new(view_context, @cohort)
  end

  # GET /cohorts/:id/students
  alias students show
end
