class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: %i[show paged_events timeline_event_show]
  before_action :skip_container, only: %i[show fee fee_submit paged_events timeline_event_show]
  before_action :require_active_subscription, only: %i[edit update]

  # GET /students/:slug
  def show
    @founder = Founder.friendly.find(params[:slug])
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

  # GET /founder/fee
  def fee
    authorize current_founder

    @payment = Startups::PendingPaymentService.new(current_startup).fetch
    @fee_form = Founders::FeeForm.new(current_founder)
    @coupon = current_startup.applied_coupon
    @coupon_form = Admissions::CouponForm.new(Reform::OpenForm.new, current_founder)

    if current_startup.level_zero?
      # Add a tag to the founders visiting the fee payment page
      current_founder.tag_list.add 'Visited Payment Page'
      current_founder.save!

      # Tag the founder on Intercom, as having visited the payment page.
      Intercom::FounderTaggingJob.perform_later(current_founder, 'Visited Payment Page')
    end
  end

  # POST /founder/fee
  def fee_submit
    authorize current_founder
    fee_form = Founders::FeeForm.new(current_founder)

    if current_startup.level_zero? && Startups::ValidateCouponUsageService.new(current_startup).invalid?
      flash[:error] = 'The coupon you applied is no longer valid. Try again!'
      redirect_to fee_founder_path
      return
    end

    if fee_form.validate(fee_params)
      payment = fee_form.save

      # Trigger the Instamojo library.
      render json: { long_url: payment.long_url }
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  # GET /students/:id/:event_title/:event_id
  def timeline_event_show
    # Reuse the startup action, because that's what this page also shows.
    show
    @timeline_event_for_og = @founder.timeline_events.find(params[:event_id])
    @meta_description = @timeline_event_for_og.description

    unless TimelineEventPolicy.new(current_user, @timeline_event_for_og).show?
      raise_not_found
    end

    render 'show'
  end

  # POST /founders/:slug/select
  def select
    founder = authorize(Founder.friendly.find(params[:id]))
    set_cookie(:founder_id, founder.id)
    redirect_to student_dashboard_url
  end

  private

  def fee_params
    params.require(:fee).permit(:billing_address, :billing_state_id)
  end

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
