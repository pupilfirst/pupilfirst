class BatchApplicationController < ApplicationController
  before_action :ensure_accurate_stage_number, only: %w(ongoing submit complete restart expired rejected)
  before_action :load_common_instance_variables
  before_action :authenticate_batch_applicant!, except: %w(index create notify)
  before_action :load_index, only: %w(index create notify)

  layout 'application_v2'

  helper_method :current_batch
  helper_method :current_application
  helper_method :application_stage
  helper_method :application_stage_number
  helper_method :stage_expired?
  helper_method :stage_active?

  # GET /apply
  def index
  end

  # POST /apply/register
  def register
    form = @batch_application.form

    if form.validate(params[:batch_application])
      begin
        applicant = form.save
      rescue Postmark::InvalidMessageError
        form.errors[:base] << t('batch_application.create.email_error')
        render 'index'
      else
        sign_in_applicant_temporarily(applicant)
        redirect_to apply_stage_path(stage_number: application_stage_number, continue_mail_sent: 'yes')
      end
    else
      render 'index'
    end
  end

  # POST /apply/notify
  def notify
    form = @prospective_applicant.form

    if form.validate(params[:prospective_applicant])
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

    case current_application&.status
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
      when nil
        redirect_to apply_path(from)
      else
        raise "Unexpected application status: #{current_application.status}"
    end
  end

  # rubocop:enable Metrics/CyclomaticComplexity

  # POST /apply/restart
  def restart_application
    # Only applications in stage 1 can restart.
    raise_not_found if application_stage_number != 1
    current_application&.restart!

    flash[:success] = 'Your previous application has been discarded.'

    redirect_to apply_path
  end

  # GET /apply/cofounders
  def cofounders_form
    if current_batch.final_stage? || application_stage_number != 2
      return redirect_to(apply_continue_path)
    end

    @form = CofoundersForm.new(current_application)
    @form.prepopulate!
  end

  # POST /apply/cofounders
  def cofounders_save
    raise_not_found if current_batch.final_stage?
    @form = CofoundersForm.new(current_application)

    if @form.validate(params[:cofounders])
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
    try "stage_#{application_stage_number}"
    render "stage_#{application_stage_number}"
  end

  # POST /apply/stage/:stage_number/submit
  def submit
    raise_not_found if current_application&.status != :ongoing

    begin
      send "stage_#{application_stage_number}_submit"
    rescue NoMethodError
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
    return redirect_to(apply_continue_path) if current_application&.status != :submitted || stage_expired?
    raise_not_found if stage_expired?

    begin
      send "stage_#{application_stage_number}_restart"
    rescue NoMethodError
      raise_not_found
    end
  end

  # GET /apply/stage/:stage_number/expired
  def expired
    return redirect_to(apply_continue_path) if current_application&.status != :expired
    try "stage_#{application_stage_number}_expired"
    render "stage_#{application_stage_number}_expired"
  end

  # GET /apply/stage/:stage_number/rejected
  def rejected
    return redirect_to(apply_continue_path) if current_application&.status != :rejected
    try "stage_#{application_stage_number}_rejected"
    render "stage_#{application_stage_number}_rejected"
  end

  ####
  ## Public methods after this after called with 'try'.
  ####

  def stage_1
    @continue_mail_sent = params[:continue_mail_sent]
    @form = ApplicationStageOneForm.new(current_application)
    @form.prepopulate!
  end

  def stage_1_submit
    # Save number of cofounders, and redirect to Instamojo.
    @form = ApplicationStageOneForm.new(current_application)

    if @form.validate(params[:application_stage_one])
      begin
        payment = @form.save
      rescue Instamojo::PaymentRequestCreationFailed
        flash[:error] = 'We were unable to contact our payment partner. Please try again in a few minutes.'
        redirect_to apply_stage_path(stage_number: 1, error: 'payment_request_failed')
        return
      end

      if Rails.env.development?
        render plain: "Redirect to #{payment.long_url}"
      else
        redirect_to payment.long_url
      end
    else
      render 'stage_1'
    end
  end

  def stage_2
    application_submission = ApplicationSubmission.new
    @form = ApplicationStageTwoForm.new(application_submission)
  end

  # TODO: Refactor this to use a decorator / view object.
  def stage_2_rejected
    @batch_application = current_application.decorate
  end

  def stage_2_submit
    application_submission = ApplicationSubmission.new(
      application_stage: ApplicationStage.find_by(number: 2),
      batch_application: current_application
    )

    @form = ApplicationStageTwoForm.new(application_submission)

    if @form.validate(params[:application_stage_two])
      @form.save
      redirect_to apply_stage_complete_path(stage_number: '2')
    else
      render 'batch_application/stage_2'
    end
  end

  def stage_2_restart
    stage_2_submission = current_application.application_submissions.where(application_stage_id: application_stage.id).first
    stage_2_submission.destroy!
    redirect_to apply_stage_path(stage_number: 2)
  end

  def stage_3
    @batch_application = current_application.decorate
  end

  def stage_3_expired
    @batch_application = current_application.decorate
  end

  def stage_3_rejected
    @batch_application = current_application.decorate
  end

  def stage_4
    @batch_application = current_application.decorate

    if @batch_application.agreements_verified
      @form = ApplicationStageFourSubmissionForm.new(@batch_application)
    elsif params[:update_profile]
      applicant = current_application.batch_applicants.find(params[:update_profile])
      @form = ApplicationStageFourApplicantForm.new(applicant)
    end
  end

  def stage_4_expired
    @batch_application = current_application.decorate
  end

  def stage_4_rejected
    @batch_application = current_application.decorate
  end

  def stage_5
    @batch = current_application.batch
  end

  # PATCH /apply/stage/4/update_applicant
  # receives founder details, generates required pdf and redirects back to updated stage_4 page
  def update_applicant
    @batch_application = current_application.decorate
    applicant = current_application.batch_applicants.find(params[:application_stage_four_applicant][:id])
    @form = ApplicationStageFourApplicantForm.new(applicant)

    if @form.validate(params[:application_stage_four_applicant])
      @form.save
      flash[:success] = 'Applicant details were successfully saved.'
      redirect_to apply_stage_path(4)
    else
      # Special dispensation, since this form can have up to four file fields. It would be super-irritating to users to
      # lose uploads to validation failure.
      @form.save_uploaded_files
      flash[:error] = 'We were unable to save applicant details because of errors. Please try again.'
      render 'stage_4'
    end
  end

  # GET /apply/stage/4/partnership_deed
  # respond with PDF version of the partnership deed created using Prawn
  def partnership_deed
    @batch_application = current_application.decorate

    unless @batch_application.partnership_deed_ready?
      flash[:error] = 'Could not generate Partnership Deed. Ensure details of all founders are provided!'
      redirect_to apply_stage_path(4)
      return
    end

    respond_to do |format|
      format.pdf do
        pdf = BatchApplications::PartnershipDeedPdfBuilderService.build(current_application)
        send_data pdf.to_pdf, type: 'application/pdf', filename: 'Partnership_Deed', disposition: 'inline'
      end
    end
  end

  # GET /apply/stage/4/incubation_agreement
  # respond with PDF version of the digital incubation services agreement created using Prawn
  def incubation_agreement
    @batch_application = current_application.decorate

    unless @batch_application.incubation_agreement_ready?
      flash[:error] = 'Could not generate Agreement. Ensure details of all founders are provided!'
      redirect_to apply_stage_path(4)
      return
    end

    respond_to do |format|
      format.pdf do
        agreement_pdf = BatchApplications::IncubationAgreementPdfBuilderService.build(current_application)
        send_data agreement_pdf.to_pdf, type: 'application/pdf', filename: 'Incubation_Agreement', disposition: 'inline'
      end
    end
  end

  def stage_4_submit
    @batch_application = current_application.decorate
    @form = ApplicationStageFourSubmissionForm.new(@batch_application)

    if @form.validate(params[:application_stage_four_submission])
      @form.save
      redirect_to apply_stage_complete_path(stage_number: '4')
    else
      @form.save_partnership_deed
      render 'stage_4'
    end
  end

  protected

  # Returns currently active batch.
  def current_batch
    @current_batch ||= begin
      current_application.batch
    end
  end

  def application_stage
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
    @application_stage_number ||= application_stage.number
  end

  # Returns batch application of current applicant.
  def current_application
    @current_application ||= begin
      if current_batch_applicant.present?
        current_batch_applicant.batch_applications.order('created_at DESC').first
      end
    end
  end

  # Batch's stage should have expired, and current stage should be same as application stage.
  def stage_expired?
    @stage_expired ||= current_batch.stage_expired?(application_stage)
  end

  def stage_active?
    @stage_active ||= current_batch.stage_active?(application_stage)
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

  def sign_in_applicant_temporarily(applicant)
    sign_in applicant.user
  end

  def authenticate_batch_applicant!
    # User must be logged in
    user = authenticate_user!

    unless user.batch_applicant.present?
      flash[:notice] = 'You are not an applicant. Please go through the registration process.'
      redirect_to apply_url
    end
  end

  def load_index
    @batch_application ||= BatchApplication.new.decorate
    @prospective_applicant ||= ProspectiveApplicant.new.decorate
  end
end
