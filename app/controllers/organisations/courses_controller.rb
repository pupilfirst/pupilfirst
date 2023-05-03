module Organisations
  class CoursesController < ApplicationController
    before_action :authenticate_user!
    before_action :find_organisation_and_course,
                  only: %i[active_cohorts inactive_cohorts]

    layout "student"

    def active_cohorts
      @active_cohorts = find_cohorts(:active)
    end

    def inactive_cohorts
      @inactive_cohorts = find_cohorts(:inactive)
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
