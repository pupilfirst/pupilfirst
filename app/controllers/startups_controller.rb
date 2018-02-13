class StartupsController < ApplicationController
  before_action :authenticate_founder!, except: %i[show index timeline_event_show paged_events]
  before_action :require_active_subscription, except: %i[index show timeline_event_show paged_events billing]

  # GET /startups
  def index
    @skip_container = true
    startups = Startup.includes(:level, :startup_categories).admitted.approved.order(timeline_updated_on: 'DESC')
    @form = Startups::FilterForm.new(Reform::OpenForm.new)

    filtered_startups, page = if @form.validate(filter_params)
      [Startups::FilterService.new(@form, startups).startups, @form.page]
    else
      [startups, 1]
    end

    @startups = filtered_startups.page(page).per(6)
    load_filter_options
  end

  def show
    @skip_container = true
    @startup = Startup.friendly.find(params[:id])
    @meta_description = "#{@startup.display_name}: #{@startup.product_description}"
    authorize @startup, :show?

    if params[:show_feedback].present?
      if current_founder.present?
        @feedback_to_show = @startup.startup_feedback.where(id: params[:show_feedback]).first if @startup.founder?(current_founder)
      else
        session[:referer] = request.original_url
        redirect_to new_user_session_path, alert: 'Please sign in to continue!'
        return
      end
    end

    @events_for_display = @startup.timeline_events_for_display(current_founder)
    @has_more_events = more_events?(@events_for_display, 1)
  end

  # GET /startups/:id/:event_title/:event_id
  def timeline_event_show
    # Reuse the startup action, because that's what this page also shows.
    show

    @timeline_event_for_og = @startup.timeline_events.find_by(id: params[:event_id])
    @meta_description = @timeline_event_for_og.description

    unless StartupPolicy.new(current_user, @startup).timeline_event_show?(@timeline_event_for_og)
      raise_not_found
    end
    render 'show'
  end

  # GET /startups/:id/events/:page
  def paged_events
    # Reuse the startup action, because that's what this page also shows.
    show
    @page = params[:page].to_i
    @has_more_events = more_events?(@events_for_display, @page)

    render layout: false
  end

  # GET /startup/edit
  def edit
    authorize current_startup
    @form = Startups::EditForm.new(current_startup)
  end

  # PATCH /startup
  def update
    authorize current_startup
    @form = Startups::EditForm.new(current_startup)

    if @form.validate(params[:startups_edit])
      @form.save!
      flash[:success] = 'Team details have been updated.'
      redirect_to timeline_path(current_startup.id, current_startup.slug)
    else
      render 'startups/edit'
    end
  end

  # POST /startup/level_up
  def level_up
    authorize current_startup

    Startups::LevelUpService.new(current_startup).execute
    redirect_to(dashboard_founder_path(from: 'level_up', from_level: current_startup.level.number - 1))
  end

  # GET /startup/billing
  def billing
    authorize current_startup
  end

  private

  def more_events?(events, page)
    return false if events.count <= 20
    events.count > page * 20
  end

  def load_filter_options
    @categories = StartupCategory.order(:name)
    @levels = Level.where('number > ?', 0).order(:number)
  end

  def startup_registration_params
    params.require(:startup).permit(:product_name)
  end

  def filter_params
    input_filter = params.include?(:startups_filter) ? params.require(:startups_filter).permit(:level_id, :search, :startup_category_id) : {}
    input_filter.merge(page: params[:page])
  end
end
