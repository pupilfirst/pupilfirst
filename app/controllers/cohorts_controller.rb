class CohortsController < ApplicationController
  before_action :authenticate_user!
  layout "student_course_v2"

  # GET /cohorts/:id
  def show
    @cohort = authorize current_school.cohorts.find(params[:id])
    @course = @cohort.course
    @presenter =
      Courses::Cohorts::StudentsPresenter.new(view_context, @course, @cohort)
  end

  # GET /cohorts/:id/students
  alias students show
end
