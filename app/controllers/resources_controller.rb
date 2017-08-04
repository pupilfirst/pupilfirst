class ResourcesController < ApplicationController
  layout 'application_v2'

  def index
    resources = policy_scope(Resource.left_joins(:level)).includes(:tags)
    @form = Resources::FilterForm.new(OpenStruct.new)

    filter_params = {}
    resources_filter = params[:resources_filter]

    if resources_filter.present?
      filter_params[:tags] = resources_filter[:tags]
      filter_params[:search] = resources_filter[:search]
      filter_params[:created_after] = resources_filter[:created_after]
    end

    filter_params[:tags] = params[:tags] if params[:tags].present?
    @filter_params = filter_params

    @resources = if @filter_params.present? && @form.validate(@filter_params.merge(page: params[:page]))
      Resources::FilterService.new(@form, resources).resources
    else
      resources.paginate(page: 1, per_page: 9)
    end

    @resource_tags = @form.resource_tags
    @skip_container = true
  end

  def show
    @resource = Resource.find(params[:id])
    authorize @resource

    return unless params[:watch].present? && @resource.stream?

    @resource.increment_downloads(current_user)
    @stream_video = @resource.file&.url || @resource.video_embed
  rescue ActiveRecord::RecordNotFound, Pundit::NotAuthorizedError
    alert_message = 'Could not find the requested resource! '

    alert_message += if current_founder.present?
      'You might not be authorized to view this resource.'
    else
      'Please try again after signing in as this could be a private resource.'
    end

    redirect_to resources_path, alert: alert_message
  end

  def download
    resource = Resource.find(params[:id])
    authorize resource
    resource.increment_downloads(current_user)
    redirect_to resource.file.url
  end
end
