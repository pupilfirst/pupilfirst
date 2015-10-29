class ResourcesController < ApplicationController
  def index
    @resources = Resource.for(current_user)
    raise_not_found if @resources.blank?
  end

  def show
    @resource = Resource.for(current_user).find(params[:id])

    return unless params[:watch].present? && @resource.stream?

    @resource.increment_downloads!
    @stream_video = @resource.file.url
  end

  def generate_download_url
    resource = Resource.for(current_user).find(params[:id])
    resource.increment_downloads!
    render json: { resource_download_url: resource.file.url }
  end
end
