class BatchApplicationController < ApplicationController
  # GET /apply
  def index
    @skip_container = true
    @batches_open = Batch.joins(:application_stage).where(application_stages: { number: 1 })
  end

  # GET /apply/:batch
  def apply
    @skip_container = true
    raise_not_found if current_stage_number.blank?
    return unless applicant_signed_in?

    if submitted_for_stage?
      render "batch_application/stage_#{current_stage_number}_submitted"
    else
      render "batch_application/stage_#{current_stage_number}"
    end
  end

  # POST /apply/:batch
  def submit
    send "submit_handler_for_stage_#{current_stage_number}"
  end

  def submit_handler_for_stage_1
    application = BatchApplication.new(
      batch: current_batch,
      application_stage: current_stage,
    )

    if application.save
      current_batch_applicant.update!(name: params[:batch_application][:team_lead_name], team_lead: true)
      application.batch_applicants << current_batch_applicant

      application.application_submissions.create(
        application_stage: current_stage,
        submission_urls: { 'Application' => admin_batch_application_url(application) }
      )

      redirect_to apply_batch_path(batch: params[:batch])
    else
      # Something about the application isn't okay.
      raise NotImplementedError
    end
  end

  # GET /apply/identify/:batch
  def identify
    check_token

    if current_batch_applicant.present?
      redirect_to apply_batch_path(batch: params[:batch])
      return
    end

    save_batch(params[:batch])

    @skip_container = true
    @batch_applicant = BatchApplicant.new
  end

  # POST /apply/identify
  def send_sign_in_email
    @skip_container = true
    @batch_applicant = BatchApplicant.find_or_initialize_by email: params[:batch_applicant][:email]

    if @batch_applicant.save
      # Regenerate token.
      @batch_applicant.regenerate_token

      # Send email.
      BatchApplicantMailer.sign_in(@batch_applicant.email, @batch_applicant.token, session[:application_batch]).deliver_later

      render 'batch_application/sign_in_email_sent'
    else
      # There's probably something wrong with the entered email address. Render the form again.
      render 'batch_application/identify'
    end
  end

  protected

  def current_stage
    @current_stage ||= begin
      current_batch&.application_stage
    end
  end

  def current_stage_number
    @current_stage_number ||= begin
      current_stage&.number
    end
  end

  # Returns currently picked batch.
  def current_batch
    @current_batch ||= begin
      Batch.find_by(name: params[:batch]) || Batch.find_by(batch_number: params[:batch])
    end
  end

  # Returns currently 'signed in' application founder.
  def current_batch_applicant
    @current_batch_applicant ||= begin
      return if cookies[:applicant_token].blank?
      BatchApplicant.find_by token: cookies[:applicant_token]
    end
  end

  helper_method :current_batch
  helper_method :current_batch_applicant

  private

  def submitted_for_stage?
    application = current_batch_applicant.batch_application

    # Applicant hasn't submitted if there is no application at all.
    return false if application.blank?

    # Applicant hasn't submitted if there is no score entry for the current stage.
    return false if ApplicationSubmission.where(
      batch_application_id: application.id,
      application_stage_id: current_stage.id
    ).blank?

    true
  end

  # def prep_for_stage_1
  #   @batch_application = BatchApplication.new
  # end

  # Check whether a token parameter has been supplied. Sign in application founder if there's a corresponding entry.
  def check_token
    return if params[:token].blank?
    applicant = BatchApplicant.find_by token: params[:token]
    return if applicant.blank?

    # Sign in the current application founder.
    @current_batch_applicant = applicant

    # Store a cookie that'll keep him / her signed in for 2 months.
    cookies[:applicant_token] = { value: applicant.token, expires: 2.months.from_now }
  end

  # Redirect to applicant sign in page is one isn't signed in.
  def applicant_signed_in?
    return true if current_batch_applicant.present?
    redirect_to apply_identify_url(batch: params[:batch])
    false
  end

  # Save the batch being requested in session. We'll add this info to the sign in link.
  def save_batch(batch)
    return if batch.blank?
    session[:application_batch] = batch
  end
end
