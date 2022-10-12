class OrganisationsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /organisations/:id
  def show
    @organisation = policy_scope(Organisation).find(params[:id])
    @cohorts = @organisation.cohorts.includes(:course).active.uniq
    @total_users_count = @organisation.users.count
  end

  # GET /organisations/index
  def index
    @organisations = policy_scope(Organisation)
  end

  # GET /organisations/:id/cohorts/:id/stats
  def cohort_stats
    @organisation = policy_scope(Organisation).find(params[:id])
    @cohort = current_school.cohorts.find(params[:cohort_id])
  end
end
