class ResourcesController < ApplicationController
  # GET /library
  def index
    resources = policy_scope(Resource)
    @form = Resources::FilterForm.new(Reform::OpenForm.new)

    filtered_resources, page = if @form.validate(filter_params)
      [Resources::FilterService.new(@form, resources).resources, @form.page]
    else
      [resources, 1]
    end

    @resources = filtered_resources.page(page).per(9)
    @skip_container = true
  end

  # GET /library/:id
  def show
    @resource = authorize(Resource.find(params[:id]))

    # If this is a video, and user has requested that it be played, increment the download count.
    @resource.increment_downloads(current_user) if params[:watch].present? && @resource.stream?
  end

  # GET /library/:id/download
  def download
    resource = authorize(Resource.find(params[:id]))
    resource.increment_downloads(current_user)
    destination = resource.link.presence || Rails.application.routes.url_helpers.rails_blob_path(resource.file, only_path: true)

    redirect_to(destination)
  end

  private

  def filter_params
    input_filter = params.include?(:resources_filter) ? params.require(:resources_filter).permit({ tags: [] }, :search, :created_after) : {}
    input_filter.merge(page: params[:page])
  end
end
