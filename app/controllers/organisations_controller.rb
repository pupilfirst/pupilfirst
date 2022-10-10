class OrganisationsController < ApplicationController
  before_action :authenticate_user!

  # GET /organisations/:id
  def show
    @organisation = policy_scope(Organisation).find(params[:id])
    @cohorts = @organisation.cohorts.includes(:course).active.uniq
    @total_users_count = @organisation.users.count
    render layout: 'student'
  end

  # GET /organisations/index
  def index
    @organisations = policy_scope(Organisation)
    render layout: 'student'
  end
end
