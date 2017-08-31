class ResourcesController < ApplicationController
  layout 'application_v2'

  # GET /library
  def index
    resources = policy_scope(Resource.left_joins(:level)).includes(:tags)
    @form = Resources::FilterForm.new(Reform::OpenForm.new)

    filtered_resources, page = if @form.validate(filter_params)
      [Resources::FilterService.new(@form, resources).resources, @form.page]
    else
      [resources, 1]
    end

    @resources = filtered_resources.paginate(page: page, per_page: 9)

    @resource_tags = @form.resource_tags
    @skip_container = true
  end

  # GET /library/resource
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

  # GET /library/resource/download
  def download
    resource = Resource.find(params[:id])
    authorize resource
    resource.increment_downloads(current_user)
    redirect_to(resource.link.present? ? resource.link : resource.file.url)
  end

  private

  def filter_params
    input_filter = params.include?(:resources_filter) ? params.require(:resources_filter).permit({ tags: [] }, :search, :created_after) : {}
    input_filter.merge(page: params[:page])
  end
end
