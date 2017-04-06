class AdmissionsController < ApplicationController
  layout 'application_v2'
  before_action :skip_container, only: %i(founders founders_submit)

  # GET /apply
  def apply
    @form = Founders::RegistrationForm.new(Founder.new)
    @form.prepopulate(current_user) if current_user.present?
  end

  # POST /apply
  def register
    @form = Founders::RegistrationForm.new(Founder.new)

    if @form.validate(params[:founders_registration])
      begin
        founder = @form.save
      rescue Postmark::InvalidMessageError
        @form.errors[:base] << t('batch_application.create.email_error')
        render 'apply'
      else
        # Sign in user immediately to allow him to proceed to screening.
        sign_in founder.user

        redirect_to dashboard_founder_path
      end
    else
      render 'apply'
    end
  end

  # GET /admissions/screening
  def screening
    authorize :admissions
  end

  # POST /admissions/screening
  def screening_submit
    authorize :admissions

    Admissions::CompleteTargetService.new(current_founder, Target::KEY_ADMISSIONS_SCREENING).execute

    flash[:success] = 'Screening target has been marked as completed!'
    redirect_to dashboard_founder_path
  end

  # GET /admissions/fee
  def fee
    authorize :admissions

    @payment_form = Admissions::PaymentForm.new(current_founder)
    @coupon = current_startup.coupons.last

    if @coupon.blank?
      @coupon_form = Admissions::CouponForm.new(OpenStruct.new)
      @coupon_form.prepopulate!(current_founder)
    end
  end

  # Payment stage submission handler.
  def fee_submit
    authorize :admissions

    # Re-direct back if applied coupon is not valid anymore
    return if applied_coupon_not_valid? || payment_bypassed?

    @form = Admissions::PaymentForm.new(current_founder)
    begin
      payment = @form.save
    rescue Instamojo::PaymentRequestCreationFailed
      flash[:error] = 'We were unable to contact our payment partner. Please try again in a few minutes.'
      redirect_to admissions_fee_path
      return
    end

    observable_redirect_to(payment.long_url)
  end

  # Handle coupon codes submissions
  def coupon_submit
    fee

    if @coupon_form.validate(params[:admissions_coupon])
      @coupon_form.apply_coupon!(current_startup)
      flash[:success] = 'Coupon applied successfully!'
      redirect_to admissions_fee_path
    else
      flash.now[:error] = 'Coupon not valid!'
      render 'fee'
    end
  end

  # Remove an applied coupon
  def coupon_remove
    authorize :admissions

    remove_latest_coupon
    flash[:success] = 'Coupon removed successfully!'
    redirect_to admissions_fee_path
  end

  # GET /admissions/founders
  def founders
    authorize :admissions
    @form = Admissions::FoundersForm.new(current_founder.startup)
    @form.prepopulate
  end

  # POST /admissions/founders
  def founders_submit
    authorize :admissions
  end

  # GET /admissions/preselection
  def preselection
    @startup = current_startup.decorate
    @founder = current_founder.decorate

    @form = if @startup.agreements_verified?
      Admissions::PreselectionStageSubmissionForm.new(current_startup)
    else
      Admissions::PreselectionStageApplicantForm.new(current_founder)
    end
  end

  # POST /admissions/preselection
  def preselection_submit; end

  private

  def skip_container
    @skip_container = true
  end

  def remove_latest_coupon
    latest_coupon = current_startup.coupons.last
    current_startup.coupon_usages.where(coupon: latest_coupon).last.delete
  end

  def applied_coupon_not_valid?
    coupon = current_startup.latest_coupon
    return false if coupon.blank? || coupon.still_valid?

    remove_latest_coupon
    flash[:error] = 'The coupon you applied is no longer valid. Try again!'
    redirect_to admissions_fee_path
    true
  end

  def payment_bypassed?
    return false unless current_startup.fee.zero? || Rails.env.development?

    bypass_payment
    true
  end

  def bypass_payment
    Admissions::PostPaymentService.new(founder: current_founder).execute
    flash[:success] = 'Payment Bypassed!'
    redirect_to dashboard_founder_path
  end
end
