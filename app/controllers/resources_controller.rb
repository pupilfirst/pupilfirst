class ResourcesController < ApplicationController
  layout 'application_v2'

  def index
    @resources = policy_scope(Resource.left_joins(:level)).includes(:tags)
    filter_resources_by_tags
    filter_resources_by_search
    filter_resources_by_date
    paginate_resources
    load_resource_tags

    @skip_container = true
  end

  def show
    @resource = Resource.find(params[:id])
    authorize @resource

    return unless params[:watch].present? && @resource.stream?

    @resource.increment_downloads(current_user)
    @stream_video = @resource.file&.url || @resource.video_embed
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
    resource = Resource.find(params[:id])
    authorize resource
    resource.increment_downloads(current_user)
    redirect_to resource.file.url
  end

  private

  def filter_resources_by_tags
    return if params[:tags].blank?
    @resources = @resources.tagged_with params[:tags]
  end

  def filter_resources_by_search
    return if params[:search].blank?
    @resources = @resources.title_matches(params[:search])
  end

  def filter_resources_by_date
    return if params[:created_after].blank?
    @resources = @resources.where('resources.created_at > ?', date_filter_values[params[:created_after].to_sym])
  end

  def paginate_resources
    # Ensure page is valid.
    page = params[:page].to_i.to_s == params[:page] ? params[:page] : nil
    @resources = @resources.paginate(page: page, per_page: 9)
  end

  def load_resource_tags
    @resource_tags = Resource.tag_counts_on(:tags).pluck(:name)
  end

  def date_filter_values
    {
      'Since Yesterday': 1.day.ago.beginning_of_day,
      'Past Week': 1.week.ago,
      'Past Month': 1.month.ago,
      'Past Year': 1.year.ago
    }
  end
end
