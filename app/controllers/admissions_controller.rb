class AdmissionsController < ApplicationController
  before_action :skip_container, only: %i[team_members team_members_submit]

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
    flash[:success] = 'You have successfully completed screening'
    redirect_to student_dashboard_path(from: 'screening_submit')
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

  # GET /admissions/team_members
  def team_members
    authorize :admissions

    fee_payment_target = Target.find_by(key: Target::KEY_FEE_PAYMENT)
    if fee_payment_target.status(current_founder) == Target::STATUS_COMPLETE
      @fee_paid = true
    else
      @form = Admissions::FoundersForm.new(current_founder.startup)
      @form.prepopulate
    end
  end

  # POST /admissions/team_members
  def team_members_submit
    team_members

    @form.current_founder = current_founder

    if @form.validate(params[:admissions_founders])
      @form.save
      flash[:success] = 'Details of team members have been saved!'
      redirect_to student_dashboard_path(from: 'founder_submit')
    else
      render 'team_members'
    end
  end

  # GET /admissions/accept_invitation?token=
  def accept_invitation
    authorize :admissions

    founder = Founder.find_by(invitation_token: params[:token])

    if founder.blank?
      flash[:error] = 'The token that was supplied is not valid.'
      redirect_to root_path
    elsif founder.startup&.level&.number&.positive?
      flash[:error] = 'Your current team has already begun the program.'
      redirect_to root_path
    else
      Founders::AcceptInvitationService.new(founder).execute
      flash[:success] = "You have successfully joined the '#{founder.reload.startup.product_name}' team."
      sign_in founder.user
      redirect_to student_dashboard_path(from: 'accept_invitation')
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
