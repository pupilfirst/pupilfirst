module Organisations
  class CoursesController < ApplicationController
    before_action :authenticate_user!
    layout "student"

    def active_cohorts
      find_organisation_and_course
      @active_cohorts = find_cohorts(:active)
      render "cohorts",
             locals: {
               cohorts: @active_cohorts,
               organisation: @organisation,
               active: true
             }
    end

    def inactive_cohorts
      find_organisation_and_course
      @ended_cohorts = find_cohorts(:inactive)
      render "cohorts",
             locals: {
               cohorts: @ended_cohorts,
               organisation: @organisation,
               active: false
             }
    end

    private

    def find_organisation_and_course
      @organisation = policy_scope(Organisation).find(params[:organisation_id])
      @course =
        authorize current_school.courses.find(params[:id]),
                  policy_class: Organisations::CoursePolicy
      @cohorts = @organisation.cohorts.where(course_id: @course.id).distinct
    end

    def find_cohorts(status)
      cohorts = status == :active ? @cohorts.active : @cohorts.ended
      paged_cohorts = cohorts.page(params["#{status}_cohort_page"]).per(10)
      if paged_cohorts.count.zero?
        paged_cohorts.page(paged_cohorts.total_pages)
      else
        paged_cohorts
      end
    end
  end
end
