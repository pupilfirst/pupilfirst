class BatchApplicationController < ApplicationController
  # GET /apply
  def index
    @skip_container = true
    @batches_open = Batch.joins(:application_stage).where(application_stages: { number: 1 })
  end

  # GET /apply/:batch
  def apply
    @skip_container = true
    @batch = Batch.find_by(name: params[:batch]) || Batch.find_by(batch_number: params[:batch])
    stage_number = @batch&.application_stage&.number
    raise_not_found if stage_number.blank?

    return unless applicant_signed_in?

    render "batch_application/stage-#{stage_number}"
  end

  # POST /apply/application
  def application

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

  # Returns currently 'signed in' application founder.
  def current_batch_applicant
    @current_batch_applicant ||= begin
      return if cookies[:applicant_token].blank?
      BatchApplicant.find_by token: cookies[:applicant_token]
    end
  end

  helper_method :current_batch_applicant

  private

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
