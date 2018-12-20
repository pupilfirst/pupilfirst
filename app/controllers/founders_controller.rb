class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: %i[show founder_profile paged_events]
  before_action :skip_container, only: %i[show founder_profile fee fee_submit paged_events]
  before_action :require_active_subscription, only: %i[edit update]

  # GET /founders/:slug, GET /students/:slug
  # TODO: FoundersController#founder_profile should probably be just #show.

  def founder_profile
    show
    render 'founder_profile'
  end

  # GET /founders/:id/events/:page
  def paged_events
    # Reuse the startup action, because that's what this page also shows.
    show
    @page = params[:page].to_i
    @has_more_events = more_events?(@events_for_display, @page)

    render layout: false
  end

  # GET /founder/edit
  def edit
    authorize current_founder
    @founder = current_founder.decorate
    @form = Founders::EditForm.new(current_founder)
  end

  # PATCH /founder
  def update
    authorize current_founder

    @founder = current_founder.decorate
    @form = Founders::EditForm.new(current_founder)

    if @form.validate(params[:founders_edit])
      @form.save!
      flash[:success] = 'Your profile has been updated.'
      redirect_to student_profile_path(slug: @founder.slug)
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

  def more_events?(events, page)
    return false if events.count <= 20

    events.count > page * 20
  end

  def show
    @founder = Founder.friendly.find(params[:slug])
    @meta_description = "#{@founder.name}: #{@founder.startup.name}"

    if params[:show_feedback].present?
      if current_founder.present?
        @feedback_to_show = @founder.startup.startup_feedback.where(id: params[:show_feedback]).first if @founder.startup.founder?(current_founder)
      else
        session[:referer] = request.original_url
        redirect_to new_user_session_path, alert: 'Please sign in to continue!'
        return
      end
    end
    @events_for_display = @founder.timeline_events_for_display(current_founder)
    @has_more_events = more_events?(@events_for_display, 1)
  end
end
