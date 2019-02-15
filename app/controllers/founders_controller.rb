class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: %i[show paged_events timeline_event_show]
  before_action :skip_container, only: %i[show paged_events timeline_event_show]

  # GET /students/:slug
  def show
    @founder = authorize(Founder.friendly.find(params[:slug]))
    # Show site wide notice to exited founders
    @sitewide_notice = @founder.exited? if @founder.user == current_user
    @meta_description = "#{@founder.name}: #{@founder.startup.name}"
    # Hide founder events from everyone other than author of event.
    @timeline_events = events_for_display.reject { |event| event.hidden_from?(current_founder) }
    @timeline_events = Kaminari.paginate_array(@timeline_events).page(params[:page]).per(20)
  end

  # GET /students/:id/events/:page
  def paged_events
    # Reuse the founder_profile action, because that's what this page also shows.
    show
    render layout: false
  end

  # GET /founder/edit
  def edit
    @founder = authorize(current_founder)
    @form = Founders::EditForm.new(current_founder)
  end

  # PATCH /founder
  def update
    @founder = authorize(current_founder)
    @form = Founders::EditForm.new(current_founder)

    if @form.validate(params[:founders_edit])
      @form.save!
      flash[:success] = 'Your profile has been updated.'
      redirect_to student_path(slug: @founder.slug)
    else
      render 'edit'
    end
  end

  # GET /students/:id/:event_title/:event_id
  def timeline_event_show
    # Reuse the startup action, because that's what this page also shows.
    show
    @timeline_event_for_og = @founder.timeline_events.find(params[:event_id])
    @meta_description = @timeline_event_for_og.description

    unless TimelineEventPolicy.new(pundit_user, @timeline_event_for_og).show?
      raise_not_found
    end

    render 'show'
  end

  # POST /founders/:slug/select
  def select
    # Use the scope from the presenter to ensure that conditions are met.
    presenter = NavLinksPresenter.new(view_context)

    founder = authorize(presenter.selectable_student_profiles.friendly.find(params[:id]))
    set_cookie(:founder_id, founder.id)
    redirect_to student_dashboard_url
  end

  private

  def skip_container
    @skip_container = true
  end

  def events_for_display
    # Only display verified of needs-improvement events if 'current_founder' is not the founder
    if current_founder != @founder
      @founder.timeline_events.passed.includes(:target, :timeline_event_files).order(:event_on, :updated_at).reverse_order
    else
      @founder.timeline_events.includes(:target, :timeline_event_files).order(:event_on, :updated_at).reverse_order
    end
  end
end
