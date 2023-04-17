class CohortsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /organisations/:organisation_id/cohorts/:id
  def show
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    @cohort = authorize current_school.cohorts.find(params[:id])

    if request.referer.present? &&
      URI(request.referer).path == "/organisations/#{@organisation.id}"
        @back_link_path = organisation_path(@organisation)
    elsif request.referer.present? &&
      URI(request.referer).path == "/organisations/#{@organisation.id}/cohorts/#{params[:id]}"
        @back_link_path = organisation_cohort_path(@organisation, @cohort)
    else
      @back_link_path = organisation_course_path(@organisation, @cohort.course)
    end

    @presenter =
      Cohorts::StudentsPresenter.new(view_context, @organisation, @cohort)
  end

  # GET /organisations/:organisation_id/cohorts/:id/students
  alias students show
end
