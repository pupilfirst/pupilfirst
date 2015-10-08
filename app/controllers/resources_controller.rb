class ResourcesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_to_founders

  def index
    @resources = current_user.startup.resources
    raise_not_found if @resources.blank?
  end

  def show
    @resource = current_user.startup.resources.find(params[:id])
  end

  def generate_download_url
    resource = current_user.startup.resources.find(params[:id])
    render json: { resource_download_url: resource.file.url }
  end

  private

  def restrict_to_founders
    return if current_user.is_founder?
    raise_not_found
  end
end
