class ResourcesController < ApplicationController
  def index
    load_resources
    filter_resources
    paginate_resources
    load_resource_tags

    @skip_container = true
  end

  def show
    @resource = Resource.for(current_founder).find(params[:id])

    return unless params[:watch].present? && @resource.stream?

    @resource.increment_downloads!
    @stream_video = @resource.file.url

  rescue ActiveRecord::RecordNotFound
    alert_message = 'Could not find the requested resource! '
    alert_message += if current_founder.present?
      'You might not be authorized to view this resource.'
    else
      'Please try again after signing in as this could be a private resource.'
    end
    redirect_to resources_path, alert: alert_message
  end

  def download
    resource = Resource.for(current_founder).find(params[:id])
    resource.increment_downloads!
    redirect_to resource.file.url
  end

  private

  def load_resources
    @resources = Resource.for(current_founder)
  end

  def filter_resources
    return if params[:tags].blank?
    @resources = @resources.tagged_with params[:tags]
  end

  def paginate_resources
    @resources = @resources.paginate(page: params[:page], per_page: 8)
  end

  def load_resource_tags
    @resource_tags = Resource.tag_counts_on(:tags).pluck(:name)
  end
end
