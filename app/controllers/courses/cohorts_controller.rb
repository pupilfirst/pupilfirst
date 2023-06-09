class Courses::CohortsController < ApplicationController
  before_action :authenticate_user!
  layout "student_course_v2"

  def show
    @course = policy_scope(Course).find(params[:course_id])
    @cohort =
      authorize current_school.cohorts.find(params[:id]),
                policy_class: Courses::CohortPolicy
    @presenter =
      Courses::Cohorts::StudentsPresenter.new(view_context, @course, @cohort)
  end

  alias students show
end
