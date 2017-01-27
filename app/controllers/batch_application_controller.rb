class BatchApplicationController < ApplicationController
  before_action :ensure_accurate_stage_number, only: %w(ongoing submit complete restart expired rejected)
  before_action :load_common_instance_variables
  before_action :authenticate_team_lead!, except: %w(index register notify)
  before_action :load_index_variables, only: %w(index register notify)

  layout 'application_v2'

  helper_method :current_application
  helper_method :current_application_round

  # GET /apply
  def index
  end

  # POST /apply/register
  def register
    form = @batch_application.form

    if form.validate(params[:batch_applications_registration])
      begin
        applicant = form.save
      rescue Postmark::InvalidMessageError
        form.errors[:base] << t('batch_application.create.email_error')
        render 'index'
      else
        # Sign in user immediately to allow him to proceed to screening.
        sign_in applicant.user

        redirect_to apply_stage_path(stage_number: application_stage_number)
      end
    else
      render 'index'
    end
  end

  # POST /apply/notify
  def notify
    form = @prospective_applicant.form

    if form.validate(params[:batch_applications_prospective_applicant])
      prospective_applicant = form.save
      session[:prospective_applicant_email] = prospective_applicant.email
      redirect_to apply_path
    else
      render 'index'
    end
  end

  # GET /apply/continue
  #
  # This is the link supplied in emails. Routes applicant to correct location.
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
  def continue
    from = params[:from].present? ? { from: params[:from] } : {}

    case current_application.status
      when :ongoing
        redirect_to apply_stage_path(from.merge(stage_number: application_stage_number))
      when :expired
        redirect_to apply_stage_expired_path(from.merge(stage_number: application_stage_number))
      when :rejected
        redirect_to apply_stage_rejected_path(from.merge(stage_number: application_stage_number))
      when :submitted
        redirect_to apply_stage_complete_path(from.merge(stage_number: application_stage_number))
      when :promoted
        redirect_to apply_stage_complete_path(from.merge(stage_number: (application_stage_number - 1)))
      else
        raise "Unexpected application status: #{current_application.status}"
    end
  end

  # rubocop:enable Metrics/CyclomaticComplexity

  # POST /apply/restart
  def restart_application
    # Only applications in stage 1 can restart.
    raise_not_found unless application_stage_number.in?([1, 2])
    current_application&.restart!

    flash[:success] = 'Your previous application has been discarded.'

    redirect_to apply_path
  end

  # GET /apply/cofounders
  def cofounders_form
    if current_application_round.final_stage? || !application_stage_number.in?([3, 4])
      return redirect_to(apply_continue_path)
    end

    @form = BatchApplications::CofoundersForm.new(current_application)
    @form.prepopulate!
  end

  # POST /apply/cofounders
  def cofounders_save
    raise_not_found if current_application_round.final_stage?
    @form = BatchApplications::CofoundersForm.new(current_application)

    if @form.validate(params[:batch_applications_cofounders])
      @form.save

      flash[:success] = 'Thank you for updating cofounder details.'
      redirect_to apply_continue_path
    else
      render 'cofounders_form'
    end
  end

  # GET /apply/stage/:stage_number
  def ongoing
    return redirect_to(apply_continue_path) if current_application&.status != :ongoing
    @batch_application = current_application.decorate
    try "stage_#{application_stage_number}"
    render "stage_#{application_stage_number}"
  end

  # POST /apply/stage/:stage_number/submit
  def submit
    raise_not_found if current_application&.status != :ongoing

    submit_method = "stage_#{application_stage_number}_submit"

    if respond_to?(submit_method)
      public_send(submit_method)
    else
      raise_not_found
    end
  end

  # GET /apply/stage/:stage_number/complete
  def complete
    return redirect_to(apply_continue_path) unless current_application&.status.in? [:submitted, :promoted]
    stage_number = (current_application&.status == :promoted ? application_stage_number - 1 : application_stage_number)
    try "stage_#{stage_number}_complete"
    render "stage_#{stage_number}_complete"
  end

  # POST /apply/stage/:stage_number/restart
  def restart
    return redirect_to(apply_continue_path) if current_application&.status != :submitted || current_application.stage_expired?

    restart_method = "stage_#{application_stage_number}_restart"

    if respond_to?(restart_method)
      public_send(restart_method)
    else
      raise_not_found
    end
  end

  # GET /apply/stage/:stage_number/expired
  def expired
    return redirect_to(apply_continue_path) if current_application&.status != :expired
    @batch_application = current_application.decorate
    try "stage_#{application_stage_number}_expired"
    render "stage_#{application_stage_number}_expired"
  end

  # GET /apply/stage/:stage_number/rejected
  def rejected
    return redirect_to(apply_continue_path) if current_application&.status != :rejected
    @batch_application = current_application.decorate
    try "stage_#{application_stage_number}_rejected"
    render "stage_#{application_stage_number}_rejected"
  end

  # PATCH /apply/stage/6/update_applicant
  # receives founder details, generates required pdf and redirects back to updated preselection stage page
  def update_applicant
    @batch_application = current_application.decorate
    applicant_params = params[:batch_applications_preselection_stage_applicant]
    applicant = current_application.batch_applicants.find(applicant_params[:id])
    @form = BatchApplications::PreselectionStageApplicantForm.new(applicant)

    if @form.validate(applicant_params)
      @form.save
      flash[:success] = 'Applicant details were successfully saved.'
      redirect_to apply_stage_path(4)
    else
      # Special dispensation, since this form can have up to four file fields. It would be super-irritating to users to
      # lose uploads to validation failure.
      @form.save_uploaded_files
      flash[:error] = 'We were unable to save applicant details because of errors. Please try again.'
      render 'stage_6'
    end
  end

  # GET /apply/stage/6/partnership_deed
  # respond with PDF version of the partnership deed created using Prawn
  def partnership_deed
    @batch_application = current_application.decorate

    unless @batch_application.partnership_deed_ready?
      flash[:error] = 'Could not generate Partnership Deed. Ensure details of all founders are provided!'
      redirect_to apply_stage_path(6)
      return
    end

    respond_to do |format|
      format.pdf do
        pdf = BatchApplications::PartnershipDeedPdfBuilderService.build(current_application)
        send_data pdf.to_pdf, type: 'application/pdf', filename: 'Partnership_Deed', disposition: 'inline'
      end
    end
  end

  # GET /apply/stage/6/incubation_agreement
  # respond with PDF version of the digital incubation services agreement created using Prawn
  def incubation_agreement
    @batch_application = current_application.decorate

    unless @batch_application.incubation_agreement_ready?
      flash[:error] = 'Could not generate Agreement. Ensure details of all founders are provided!'
      redirect_to apply_stage_path(6)
      return
    end

    respond_to do |format|
      format.pdf do
        agreement_pdf = BatchApplications::IncubationAgreementPdfBuilderService.build(current_application)
        send_data agreement_pdf.to_pdf, type: 'application/pdf', filename: 'Incubation_Agreement', disposition: 'inline'
      end
    end
  end

  ####
  ## Public methods after this after called with 'try'.
  ####

  # Screening submission handler.
  def stage_1_submit
    new_application_stage = current_application.promote!

    if new_application_stage.number == 2
      redirect_to apply_stage_path(stage_number: 2)
    else
      raise "Unable to promote BatchApplication##{current_application.id} to Stage 2. Please inspect."
    end
  end

  # Payment stage.
  def stage_2
    @payment_form = BatchApplications::PaymentForm.new(current_application)
    @coupon = current_application.coupons.last
    @coupon_form = BatchApplications::CouponForm.new(OpenStruct.new) unless @coupon.present?
  end

  # Handle coupon codes submissions
  def coupon_submit
    stage_2

    if @coupon_form.validate(params[:batch_applications_coupon])
      @coupon_form.apply_coupon!(current_application)
      flash[:success] = 'Coupon applied successfully!'
      redirect_to apply_stage_path(stage_number: 2)
    else
      flash.now[:error] = 'Coupon not valid!'
      render 'stage_2'
    end
  end

  # Remove an applied coupon
  def coupon_remove
    remove_latest_coupon
    flash[:success] = 'Coupon removed successfully!'
    redirect_to apply_stage_path(stage_number: 2)
  end

  # Payment stage submission handler.
  def stage_2_submit
    # Re-direct back if applied coupon is not valid anymore
    return if applied_coupon_not_valid?

    # Save number of cofounders, and redirect to Instamojo.
    @form = BatchApplications::PaymentForm.new(current_application)

    if @form.validate(params[:batch_applications_payment])
      return if payment_bypassed?

      begin
        payment = @form.save
      rescue Instamojo::PaymentRequestCreationFailed
        flash[:error] = 'We were unable to contact our payment partner. Please try again in a few minutes.'
        redirect_to apply_stage_path(stage_number: 2, error: 'payment_request_failed')
        return
      end

      redirect_to payment.long_url
    else
      render 'stage_1'
    end
  end

  # Perform post payment tasks and promote to stage 3
  def bypass_payment
    # save the team size
    current_application.update!(team_size: params[:batch_applications_payment][:team_size])
    current_application.perform_post_payment_tasks!
    IntercomLastApplicantEventUpdateJob.perform_later(current_application.team_lead, 'payment_skipped')
    redirect_to apply_stage_path(stage_number: 3)
  end

  # Coding stage
  def stage_3
    @form = BatchApplications::CodingStageForm.new(OpenStruct.new)
  end

  # Coding stage submissions handler.
  def stage_3_submit
    @form = BatchApplications::CodingStageForm.new(OpenStruct.new)

    if @form.validate(params[:batch_applications_coding_stage])
      @form.save(current_application)
      redirect_to apply_stage_complete_path(stage_number: '3')
    else
      render 'batch_application/stage_3'
    end
  end

  # Coding stage restart handler.
  def stage_3_restart
    BatchApplication.transaction do
      stage_3_submission = current_application.application_submissions.where(application_stage_id: current_application_stage.id).first
      stage_3_submission.destroy!

      # Also reset the generate_certificate flag.
      current_application.update!(generate_certificate: false)
    end

    redirect_to apply_stage_path(stage_number: 3)
  end

  # Video stage
  def stage_4
    @form = BatchApplications::VideoStageForm.new(current_application)
  end

  # Video stage submissions handler.
  def stage_4_submit
    @form = BatchApplications::VideoStageForm.new(current_application)

    if @form.validate(params[:batch_applications_video_stage])
      @form.save(current_application)
      redirect_to apply_stage_complete_path(stage_number: '4')
    else
      render 'batch_application/stage_4'
    end
  end

  # Video stage restart handler.
  def stage_4_restart
    stage_4_submission = current_application.application_submissions.where(application_stage_id: current_application_stage.id).first
    stage_4_submission.destroy!
    redirect_to apply_stage_path(stage_number: 4)
  end

  # Pre-selection stage.
  def stage_6
    if @batch_application.agreements_verified
      @form = BatchApplications::PreselectionStageSubmissionForm.new(@batch_application)
    elsif params[:update_profile]
      applicant = current_application.batch_applicants.find(params[:update_profile])
      @form = BatchApplications::PreselectionStageApplicantForm.new(applicant)
    end
  end

  # Pre-selection submission handler.
  def stage_6_submit
    @batch_application = current_application.decorate
    @form = BatchApplications::PreselectionStageSubmissionForm.new(@batch_application)

    if @form.validate(params[:batch_applications_preselection_stage_submission])
      @form.save
      redirect_to apply_stage_complete_path(stage_number: '4')
    else
      @form.save_partnership_deed
      render 'stage_6'
    end
  end

  # Closed stage.
  def stage_7
    @batch = current_application.batch
  end

  protected

  # Returns currently active batch.
  def current_application_round
    @current_application_round ||= begin
      current_application.application_round
    end
  end

  def current_application_stage
    @application_stage ||= begin
      if current_application.blank?
        ApplicationStage.find_by number: 1
      else
        current_application.application_stage
      end
    end
  end

  # Returns stage number of current applicant.
  def application_stage_number
    @application_stage_number ||= current_application_stage.number
  end

  # Returns batch application of current applicant.
  def current_application
    @current_application ||= begin
      if current_batch_applicant.present?
        current_batch_applicant.applications_as_team_lead.order('created_at DESC').first&.decorate
      end
    end
  end

  private

  def load_common_instance_variables
    @skip_container = true
    @hide_sign_in = true
    @hide_nav_links = true
  end

  # Make sure that the stage number supplied in the URL matches application's state.
  def ensure_accurate_stage_number
    # If the application has been promoted, but batch is still at the earlier stage, the displayed stage number will be
    # one less than the application's stage.
    expected_stage_number = (current_application&.status == :promoted ? application_stage_number - 1 : application_stage_number)
    redirect_to apply_continue_path if params[:stage_number].to_i != expected_stage_number
  end

  def authenticate_team_lead!
    # User must be logged in
    authenticate_user!

    unless current_user.batch_applicant.present?
      flash[:notice] = 'You are not an applicant. Please go through the registration process.'
      redirect_to apply_url
      return
    end

    unless current_user.batch_applicant.batch_applications.any?
      flash[:notice] = 'You have not submitted an application. Please go through the registration process.'
      redirect_to apply_url
      return
    end

    unless current_application.present?
      flash[:notice] = 'You are part of an application, but are not the team lead. If you wish to create a new application as team lead, please go through the registration process.'
      redirect_to apply_url
    end
  end

  def load_index_variables
    @batch_application ||= BatchApplication.new.decorate
    @prospective_applicant ||= ProspectiveApplicant.new.decorate
  end

  def remove_latest_coupon
    latest_coupon = current_application.coupons.last
    current_application.coupon_usages.where(coupon: latest_coupon).last.delete
  end

  def applied_coupon_not_valid?
    coupon = current_application.latest_coupon
    return false if coupon.blank? || coupon.still_valid?

    remove_latest_coupon
    flash[:error] = 'The coupon you applied is no longer valid. Try again!'
    redirect_to apply_stage_path(stage_number: 2)
    true
  end

  def payment_bypassed?
    return false unless current_application.fee.zero? || Rails.env.development?

    bypass_payment
    true
  end
end
