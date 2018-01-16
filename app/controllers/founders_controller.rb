class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: :founder_profile
  before_action :skip_container, only: %i[founder_profile fee fee_submit]
  before_action :require_active_subscription, only: %i[edit update]

  # layout 'application_v2', only: %i[fee fee_submit]

  # GET /founders/:slug
  #
  # TODO: FoundersController#founder_profile should probably be just #show.
  def founder_profile
    @founder = Founder.friendly.find(params[:slug])
    authorize @founder
    @timeline = Founders::ActivityTimelineService.new(@founder, params[:to])
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
      redirect_to founder_profile_path(slug: @founder.slug)
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

  private

  def fee_params
    params.require(:fee).permit(:billing_address, :billing_state_id)
  end

  def skip_container
    @skip_container = true
  end
end
