class Courses::CohortsController < ApplicationController
  before_action :authenticate_user!

  def show
    @course = policy_scope(Course).find(params[:course_id])
    @cohort = authorize current_school.cohorts.find(params[:id])

    render html: "twaing", layout: "student_course_v2"
  end
end
