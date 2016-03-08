class ResourcesController < ApplicationController
  def index
    @resources = Resource.for(current_founder)
    raise_not_found if @resources.blank?
    @skip_container = true
  end

  def show
    @resource = Resource.for(current_founder).find(params[:id])

    return unless params[:watch].present? && @resource.stream?

    @resource.increment_downloads!
    @stream_video = @resource.file.url
  end

  def download
    resource = Resource.for(current_founder).find(params[:id])
    resource.increment_downloads!
    redirect_to resource.file.url
  end
end
