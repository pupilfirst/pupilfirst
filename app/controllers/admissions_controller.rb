class AdmissionsController < ApplicationController
  before_action :skip_container, only: %i[join register founders founders_submit]

  # GET /apply
  def apply
    @form = if Feature.active?(:admissions, current_user)
      Founders::RegistrationForm.new(Founder.new)
    else
      ProspectiveApplicants::RegistrationForm.new(Founder.new)
    end

    @form.prepopulate(current_user) if current_user.present?
    render layout: 'application'
  end

  # POST /apply
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

    render 'apply', layout: 'application'
  end

  # GET /admissions/screening
  def screening
    authorize :admissions

    screening_url = if Rails.env.development?
      Admissions::CompleteTargetService.new(current_founder, Target::KEY_SCREENING).execute
      admissions_screening_submit_url
    else
      Rails.application.secrets.typeform[:screening_url] + "?user_id=#{current_user.id}"
    end

    redirect_to screening_url
  end

  # GET /admissions/screening_submit?user_id&score
  def screening_submit
    authorize :admissions
    flash[:success] = 'Your submission has been recorded!'
    redirect_to dashboard_founder_path(from: 'screening_submit')
  end

  def screening_submit_webhook
    founder = Founder.find_by user_id: params.dig(:form_response, :hidden, :user_id).to_i
    screening_response = params.dig(:form_response).permit!.to_h

    if founder.present? && founder.screening_data.blank?
      Admissions::ScreeningCompletionJob.perform_later(founder, screening_response)
    end

    head :ok
  end

  # POST /admissions/coupon_submit
  #
  # Handle submission of coupon code.
  def coupon_submit
    authorize :admissions

    coupon_form = Admissions::CouponForm.new(Reform::OpenForm.new, current_founder)

    if coupon_form.validate(params[:admissions_coupon])
      coupon_form.apply_coupon

      # Send coupon details and updated fee details.
      render json: Startups::FeeAndCouponDataService.new(current_startup.reload).props
    else
      render json: { errors: coupon_form.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /admissions/coupon_remove
  #
  # Remove an applied coupon.
  def coupon_remove
    authorize :admissions

    remove_latest_coupon
    render json: Startups::FeeAndCouponDataService.new(current_startup.reload).props
  end

  # GET /admissions/founders
  def founders
    authorize :admissions

    fee_payment_target = Target.find_by(key: Target::KEY_FEE_PAYMENT)
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
      flash[:success] = "You have successfully joined #{founder.reload.startup.team_lead.name}'s startup"
      sign_in founder.user
      redirect_to dashboard_founder_path(from: 'accept_invitation')
    end
  end

  private

  def skip_container
    @skip_container = true
  end

  def remove_latest_coupon
    current_startup.coupon_usage.destroy!
  end
end
