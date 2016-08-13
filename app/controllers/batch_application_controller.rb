class BatchApplicationController < ApplicationController
  before_action :ensure_applicant_is_signed_in, except: %w(index register identify send_sign_in_email continue sign_in_email_sent)
  before_action :ensure_accurate_stage_number, only: %w(ongoing submit complete restart expired rejected)
  before_action :load_common_instance_variables

  layout 'application_v2'

  helper_method :current_batch_applicant
  helper_method :current_batch
  helper_method :current_application
  helper_method :application_stage
  helper_method :application_stage_number
  helper_method :application_status
  helper_method :stage_expired?
  helper_method :stage_active?

  # GET /apply
  def index
    @form = BatchApplicationForm.new(BatchApplication.new)
    @form.prepopulate!(team_lead: BatchApplicant.new)
    @open_batch = Batch.open_batch
  end

  # POST /apply/register
  def register
    batch_application = BatchApplication.new
    batch_application.team_lead = BatchApplicant.new
    @form = BatchApplicationForm.new(batch_application)

    if @form.validate(params[:batch_application])
      applicant = @form.save

      sign_in_applicant_temporarily(applicant)

      redirect_to apply_stage_path(stage_number: application_stage_number, continue_mail_sent: 'yes')
    else
      render 'index'
    end
  end

  # GET /apply/identify
  def identify
    @form = BatchApplicantSignInForm.new(BatchApplicant.new)
  end

  # POST /apply/send_sign_in_email
  def send_sign_in_email
    @skip_container = true

    @form = BatchApplicantSignInForm.new(BatchApplicant.new)

    if @form.validate(params[:batch_applicant_sign_in])
      @form.save

      # Kick out session based login if a manual login is requested. This allows applicant to change signed-in ID.
      session.delete :applicant_token

      redirect_to apply_sign_in_email_sent_path(batch_number: params[:batch_number])
    else
      render 'batch_application/identify'
    end
  end

  # GET /apply/sign_in_email_sent
  def sign_in_email_sent
    @skip_container = true
  end

  # GET /apply/continue
  #
  # This is the link supplied in emails. Routes applicant to correct location.
  # rubocop:disable Metrics/CyclomaticComplexity
  def continue
    check_token

    case application_status
      when :pending
        redirect_to apply_path
      when :batch_pending
        redirect_to apply_batch_pending_path
      when :ongoing
        redirect_to apply_stage_path(stage_number: application_stage_number)
      when :expired
        redirect_to apply_stage_expired_path(stage_number: application_stage_number)
      when :rejected
        redirect_to apply_stage_rejected_path(stage_number: application_stage_number)
      when :submitted
        redirect_to apply_stage_complete_path(stage_number: application_stage_number)
      when :promoted
        redirect_to apply_stage_complete_path(stage_number: (application_stage_number - 1))
      else
        raise "Unexpected application_status: #{application_status}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # GET /apply/batch_pending
  def batch_pending
    return redirect_to(apply_continue_path) if applicant_status != :batch_pending
  end

  # POST /apply/restart
  def restart_application
    # Only applications in stage 1 can restart.
    raise_not_found if application_stage_number != 1
    current_application&.restart!

    flash[:success] = 'Your previous application has been discarded.'

    redirect_to apply_path
  end

  # GET /apply/stage/:stage_number
  def ongoing
    return redirect_to(apply_continue_path) if application_status != :ongoing
    try "stage_#{application_stage_number}"
    render "stage_#{application_stage_number}"
  end

  # POST /apply/stage/:stage_number/submit
  def submit
    raise_not_found if application_status != :ongoing

    begin
      send "stage_#{application_stage_number}_submit"
    rescue NoMethodError
      raise_not_found
    end
  end

  # GET /apply/stage/:stage_number/complete
  def complete
    return redirect_to(apply_continue_path) unless application_status.in? [:complete, :promoted]
    stage_number = (application_status == :promoted ? application_stage_number - 1 : application_stage_number)
    try "stage_#{stage_number}_complete"
    render "stage_#{stage_number}_complete"
  end

  # POST /apply/stage/:stage_number/restart
  def restart
    return redirect_to(apply_continue_path) if application_status != :complete
    raise_not_found if stage_expired?

    begin
      send "stage_#{application_stage_number}_restart"
    rescue NoMethodError
      raise_not_found
    end
  end

  # GET /apply/stage/:stage_number/expired
  def expired
    return redirect_to(apply_continue_path) if application_status != :expired
    try "stage_#{application_stage_number}_expired"
    render "stage_#{application_stage_number}_expired"
  end

  # GET /apply/stage/:stage_number/rejected
  def rejected
    return redirect_to(apply_continue_path) if application_status != :rejected
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
        render text: "Redirect to #{payment.long_url}"
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

  def stage_4_submit
    # TODO: Server-side error handling for stage 4 inputs.

    # TODO: How to handle file uploads (if any for pre-selection)?
    current_application.application_submissions.create!(
      application_stage: ApplicationStage.find_by(number: 4)
    )

    redirect_to apply_stage_complete_path(stage_number: '4')
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
        if session[:application_selected_batch_id].present?
          selected_batch = Batch.find session[:application_selected_batch_id]
          current_batch_applicant.batch_applications.find_by(batch: selected_batch)
        else
          current_batch_applicant.batch_applications.order('created_at DESC').first
        end
      end
    end
  end

  # Returns currently 'signed in' application founder.
  def current_batch_applicant
    @current_batch_applicant ||= begin
      token = session[:applicant_token] || cookies[:applicant_token]
      BatchApplicant.find_by token: token
    end
  end

  # Returns one of :pending, :ongoing, :expired, :rejected, :complete, or :promoted to indicate which view should be
  # rendered.
  def application_status
    @application_status ||= (current_application&.status || :pending)
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

  # Check whether a token parameter has been supplied. Sign in application founder if there's a corresponding entry.
  def check_token
    return if params[:token].blank?
    applicant = BatchApplicant.find_by token: params[:token]

    if applicant.blank?
      flash[:error] = 'That token is invalid.'
      return
    end

    # Sign in the current application founder.
    @current_batch_applicant = applicant

    if params[:shared_device] == 'true'
      # If applicant has indicated that zhe is on a shared device, create session variable instead of cookie.
      session[:applicant_token] = applicant.token
    else
      # Store a cookie that'll keep applicant signed in for 3 months.
      cookies[:applicant_token] = { value: applicant.token, expires: 3.months.from_now }
    end
  end

  # Redirect applicant to sign in page is zhe isn't signed in.
  def ensure_applicant_is_signed_in
    return if current_batch_applicant.present?
    redirect_to apply_identify_url(batch: params[:batch_number])
  end

  # Make sure that the stage number supplied in the URL matches application's state.
  def ensure_accurate_stage_number
    # If the application has been promoted, but batch is still at the earlier stage, the displayed stage number will be
    # one less than the application's stage.
    expected_stage_number = (application_status == :promoted ? application_stage_number - 1 : application_stage_number)
    redirect_to apply_continue_path if params[:stage_number].to_i != expected_stage_number
  end

  def sign_in_applicant_temporarily(applicant)
    session[:applicant_token] = applicant.token
  end
end
