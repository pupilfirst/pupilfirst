module Organisations
  class CoursesController < ApplicationController
    before_action :authenticate_user!
    layout 'student'

    def show
      @organisation = policy_scope(Organisation).find(params[:organisation_id])
      @course = authorize current_school.courses.find(params[:id])

      @cohorts = @organisation.cohorts.where(course_id: @course.id).distinct
      @ended_cohorts = @cohorts.ended.page(params[:ended_cohort_page]).per(10)
      @active_cohorts = @cohorts.active.page(params[:active_cohort_page]).per(10)
    end
  end
end
