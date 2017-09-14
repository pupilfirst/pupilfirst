class FoundersController < ApplicationController
  before_action :authenticate_founder!, except: :founder_profile
  before_action :skip_container, only: %i[founder_profile fee fee_submit]
  before_action :require_active_subscription, only: %i[edit update]

  layout 'application_v2', only: %i[fee fee_submit]

  # GET /founders/:slug
  #
  # TODO: FoundersController#founder_profile should probably be just #show.
  def founder_profile
    @founder = Founder.friendly.find(params[:slug])
    authorize @founder

    @timeline = @founder.activity_timeline
  end

  # GET /founder/edit
  def edit
    @founder = current_founder.decorate
    authorize current_founder
  end

  # PATCH /founder
  def update
    @founder = current_founder.decorate
    authorize @founder.model
    form = @founder.form

    if form.validate(params[:founders_edit])
      form.save!
      flash[:success] = 'Your profile has been updated.'
      redirect_to founder_profile_path(slug: @founder.slug)
    else
      render 'edit'
    end
  end

  # GET /founder/fee
  def fee
    @founder = current_founder
    authorize @founder
    @payment = Founders::PendingPaymentService.new(@founder).fetch
    @fee_form = Founders::FeeForm.new(@founder)
    @coupon = current_startup.applied_coupon
    @coupon_form = Admissions::CouponForm.new(Reform::OpenForm.new, current_founder)
  end

  # POST /founder/fee
  def fee_submit
    authorize current_founder
    fee_form = Founders::FeeForm.new(current_founder)

    if fee_form.validate(fee_params)
      payment = fee_form.save

      # Trigger the Instamojo library.
      render js: "Instamojo.open('#{payment.long_url}');"
    else
      render js: 'alert("Something went wrong! Please refresh the page and try again.");'
    end
  end

  private

  def fee_params
    params.require(:fee).permit(:period)
  end

  def skip_container
    @skip_container = true
  end
end
