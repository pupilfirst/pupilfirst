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

    if current_application_founder.present?
      redirect_to apply_batch_path(batch: params[:batch])
      return
    end

    save_batch(params[:batch])

    @skip_container = true
    @application_founder = ApplicationFounder.new
  end

  # POST /apply/identify
  def send_sign_in_email
    @skip_container = true
    @application_founder = ApplicationFounder.find_or_initialize_by email: params[:application_founder][:email]

    if @application_founder.save
      # Regenerate token.
      @application_founder.regenerate_token

      # Send email.
      ApplicationFounderMailer.sign_in(@application_founder.email, @application_founder.token, session[:application_batch]).deliver_later

      render 'batch_application/sign_in_email_sent'
    else
      # There's probably something wrong with the entered email address. Render the form again.
      render 'batch_application/identify'
    end
  end

  protected

  # Returns currently 'signed in' application founder.
  def current_application_founder
    @current_application_founder ||= begin
      return if cookies[:applicant_token].blank?
      ApplicationFounder.find_by token: cookies[:applicant_token]
    end
  end

  helper_method :current_application_founder

  private

  # Check whether a token parameter has been supplied. Sign in application founder if there's a corresponding entry.
  def check_token
    return if params[:token].blank?
    applicant = ApplicationFounder.find_by token: params[:token]
    return if applicant.blank?

    # Sign in the current application founder.
    @current_application_founder = applicant

    # Store a cookie that'll keep him / her signed in for 2 months.
    cookies[:applicant_token] = { value: applicant.token, expires: 2.months.from_now }
  end

  # Redirect to applicant sign in page is one isn't signed in.
  def applicant_signed_in?
    return true if current_application_founder.present?
    redirect_to apply_identify_url(batch: params[:batch])
    false
  end

  # Save the batch being requested in session. We'll add this info to the sign in link.
  def save_batch(batch)
    return if batch.blank?
    session[:application_batch] = batch
  end
end
