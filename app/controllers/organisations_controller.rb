class OrganisationsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  # GET /organisations/:id
  def show
    @organisation = policy_scope(Organisation).find(params[:id])
    @cohorts = @organisation.cohorts.includes(:course).active.uniq
    @total_users_count = @organisation.users.count
  end

  # GET /organisations
  def index
    @organisations = policy_scope(Organisation)
  end
end
