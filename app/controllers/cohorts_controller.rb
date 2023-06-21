class CohortsController < ApplicationController
  before_action :authenticate_user!
  layout "student_course_v2"

  def show
    @cohort = authorize current_school.cohorts.find(params[:id])
    @course = @cohort.course
    @presenter =
      Courses::Cohorts::StudentsPresenter.new(view_context, @course, @cohort)
  end

  alias students show
end
