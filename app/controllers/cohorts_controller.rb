class CohortsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /organisations/:organisation_id/cohorts/:id
  def show
    @organisation = policy_scope(Organisation).find(params[:organisation_id])
    @cohort = authorize current_school.cohorts.find(params[:id])

    if request.referer.include?("organisations/#{params[:organisation_id]}/courses/#{params[:id]}")
      @back_link_path = organisation_course_path(params[:organisation_id], params[:id])
    else
      @back_link_path = organisation_path(@organisation)
    end

    @presenter =
      Cohorts::StudentsPresenter.new(view_context, @organisation, @cohort)
  end

  # GET /organisations/:organisation_id/cohorts/:id/students
  alias students show
end
