class AdmissionsController < ApplicationController
  layout 'application_v2'
  before_action :skip_container, only: %i[join register founders founders_submit fee]

  # GET /join
  def join
    @form = Founders::RegistrationForm.new(Founder.new)
    @form.prepopulate(current_user) if current_user.present?
  end

  # POST /join
  def register
    @form = Founders::RegistrationForm.new(Founder.new)

    if verify_recaptcha(model: @form, secret_key: Rails.application.secrets.dig(:google, :recaptcha, :invisible, :secret_key))
      if @form.validate(params[:founders_registration])
        begin
          founder = @form.save
        rescue Postmark::InvalidMessageError
          @form.errors[:base] << t('admissions.register.email_error')
        else
          # Sign in user immediately to allow him to proceed to screening.
          sign_in founder.user

          redirect_to dashboard_founder_path(from: 'register')
          return
        end
      else
        flash.now[:error] = 'There were problems with your submission. Please check the form and retry.'
      end
    end

    render 'join'
  end

  # GET /admissions/screening
  def screening
    authorize :admissions
  end

  # POST /admissions/screening
  def screening_submit
    authorize :admissions

    Admissions::CompleteTargetService.new(current_founder, Target::KEY_ADMISSIONS_SCREENING).execute

    # Mark founder skill - Hacker or Hustler?
    current_founder.update!(hacker: params['founder_skill'] == 'coder', github_url: params['github_url'])
    skill = if params['founder_skill'] == 'coder'
      params['github_url'].present? ? 'Hacker with Github' : 'Hacker'
    else
      'Hustler'
    end
    Intercom::FounderSkillUpdateJob.perform_later(current_founder, skill)

    # Mark as screening completed on Intercom
    Intercom::LevelZeroStageUpdateJob.perform_later(current_founder, 'Screening Completed')

    flash[:success] = 'Screening target has been marked as completed!'
    redirect_to dashboard_founder_path(from: 'screening_submit')
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
      @coupon_form.apply_coupon
      flash[:success] = 'Coupon applied successfully!'
      redirect_to admissions_fee_path
    else
      flash.now[:error] = 'Coupon code is not valid!'
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

    fee_payment_target = Target.find_by(key: Target::KEY_ADMISSIONS_FEE_PAYMENT)
    if fee_payment_target.status(current_founder) == Targets::StatusService::STATUS_COMPLETE
      @fee_paid = true
    else
      @form = Admissions::FoundersForm.new(current_founder.startup)
      @form.prepopulate
    end
  end

  # POST /admissions/founders
  def founders_submit
    founders

    @form.current_founder = current_founder

    if @form.validate(params[:admissions_founders])
      @form.save
      flash[:success] = 'Details of founders have been saved!'
      redirect_to dashboard_founder_path(from: 'founder_submit')
    else
      render 'founders'
    end
  end

  # POST /admissions/team_lead
  def team_lead
    Founders::BecomeTeamLeadService.new(current_founder).execute
    flash[:success] = 'You are now the team lead!'
    redirect_back(fallback_location: admissions_founders_path)
  end

  # GET /admissions/accept_invitation?token=
  def accept_invitation
    authorize :admissions

    founder = Founder.find_by(invitation_token: params[:token])

    if founder.blank?
      flash[:error] = 'The token that was supplied is not valid.'
      redirect_to root_path
    elsif founder.startup&.level&.number&.positive?
      flash[:error] = 'Your current startup has already begun the program.'
      redirect_to root_path
    else
      Founders::AcceptInvitationService.new(founder).execute
      flash[:success] = "You have successfully joined #{founder.reload.startup.admin.name}'s startup"
      sign_in founder.user
      redirect_to dashboard_founder_path(from: 'accept_invitation')
    end
  end

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
    redirect_to dashboard_founder_path(from: 'bypass_payment')
  end
end
