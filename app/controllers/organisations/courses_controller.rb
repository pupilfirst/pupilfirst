module Organisations
  class CoursesController < ApplicationController
    before_action :authenticate_user!
    layout 'student'

    def active_cohorts
      @organisation = policy_scope(Organisation).find(params[:organisation_id])
      @course = authorize current_school.courses.find(params[:id]), policy_class: Organisations::CoursePolicy

      @cohorts = @organisation.cohorts.where(course_id: @course.id).distinct
      @ended_cohorts = @cohorts.ended.page(params[:ended_cohort_page]).per(10)
      @active_cohorts = @cohorts.active.page(params[:active_cohort_page]).per(10)
    end

    def inactive_cohorts
      @organisation = policy_scope(Organisation).find(params[:organisation_id])
      @course = authorize current_school.courses.find(params[:id]), policy_class: Organisations::CoursePolicy

      @cohorts = @organisation.cohorts.where(course_id: @course.id).distinct
      @ended_cohorts = @cohorts.ended.page(params[:ended_cohort_page]).per(10)
    end
  end
end
