class ResourcesController < ApplicationController
  def index
    @resources = Resource.for(current_user)
    raise_not_found if @resources.blank?
  end

  def show
    @resource = Resource.for(current_user).find(params[:id])
  end

  def generate_download_url
    resource = Resource.for(current_user).find(params[:id])
    render json: { resource_download_url: resource.file.url }
  end
end
