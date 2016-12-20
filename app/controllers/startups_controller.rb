class StartupsController < ApplicationController
  before_action :authenticate_founder!, except: [:show, :index]
  before_action :restrict_to_startup_founders, only: [:edit, :update]

  # GET /startups
  def index
    load_startups
    load_filter_options
    @skip_container = true
  end

  def show
    @skip_container = true
    @startup = Startup.friendly.find(params[:id])
    if params[:show_feedback].present?
      if current_founder.present?
        @feedback_to_show = @startup.startup_feedback.where(id: params[:show_feedback]).first if @startup.founder?(current_founder)
      else
        session[:referer] = request.original_url
        redirect_to new_user_session_path, alert: 'Please sign in to continue!'
      end
    end
    @timeline_event = timeline_event_for_builder
  end

  def edit
    @startup = current_founder.startup
  end

  def update
    @current_founder = current_founder
    @startup = @current_founder.startup
    @startup.validate_web_mandatory_fields = true

    if @startup.update(startup_params)
      flash[:success] = 'Startup details have been updated.'
      redirect_to @startup
    else
      render 'startups/edit'
    end
  end

  private

  def load_startups
    batch_id = params.dig(:startups_filter, :batch)
    batch_scope = batch_id.present? ? Startup.where(batch_id: batch_id) : Startup.batched

    category_id = params.dig(:startups_filter, :category)
    category_scope = category_id.present? ? Startup.joins(:startup_categories).where(startup_categories: { id: category_id }) : Startup.unscoped

    stage = params.dig(:startups_filter, :stage)
    stage_scope = stage.present? ? Startup.where(stage: stage) : Startup.unscoped

    unsorted_startups = Startup.approved.merge(batch_scope).merge(category_scope).merge(stage_scope)

    # HACK: account for startups with latest_team_event_date = nil while sorting
    @startups = unsorted_startups.select(&:latest_team_event_date).sort_by(&:latest_team_event_date).reverse + unsorted_startups.reject(&:latest_team_event_date)
  end

  def load_filter_options
    @batches = Startup.available_batches.order('batch_number DESC')
    @categories = StartupCategory.joins(:startups).where.not(startups: { batch_id: nil }).distinct
    @stages = Startup.batched.pluck(:stage).uniq
  end

  def startup_params
    params.require(:startup).permit(
      :legal_registered_name, :address, :pitch, :website, :email, :logo, :remote_logo_url, :facebook_link,
      :twitter_link, :product_name, :product_description,
      { startup_category_ids: [] }, { founders_attributes: [:id] },
      :registration_type, :presentation_link, :product_video_link, :wireframe_link, :prototype_link, :slug
    )
  end

  def startup_registration_params
    params.require(:startup).permit(:product_name)
  end

  def startup_destroy_params
    params.require(:startup).permit(:password)
  end

  def restrict_to_startup_founders
    return if current_founder
    raise_not_found
  end

  # If an event_id is available, use that, otherwise supply a new timeline event.
  def timeline_event_for_builder
    if params[:event_id]
      @startup.timeline_events.find(params[:event_id])
    else
      @startup.timeline_events.new
    end
  end
end
