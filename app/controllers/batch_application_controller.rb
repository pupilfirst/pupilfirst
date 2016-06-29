class BatchApplicationController < ApplicationController
  before_action :lock_under_feature_flag
  before_action :ensure_applicant_is_signed_in, only: :apply
  layout 'application_v2'

  # GET /apply
  def index
    set_instance_variables
    @batches_open = Batch.open_for_applications
    @batches_ongoing = Batch.applications_ongoing
  end

  # GET /apply/:batch
  #
  # rubocop:disable Metrics/CyclomaticComplexity
  def apply
    set_instance_variables
    raise_not_found if current_stage_number == 0

    case applicant_status
      when :application_pending
        prep_for_stage_1
        render 'batch_application/stage_1'
      when :application_expired
        render 'batch_application/stage_1_expired'
      when :payment_pending
        render 'batch_application/stage_1_submitted'
      when :expired
        render "batch_application/stage_#{applicant_stage_number}_expired"
      when :rejected
        render "batch_application/stage_#{applicant_stage_number}_rejection"
      when :submitted
        render "batch_application/stage_#{current_stage_number}_submitted"
      else
        send "prep_for_stage_#{current_stage_number}"
        render "batch_application/stage_#{current_stage_number}"
    end
  end

  # POST /apply/:batch
  def submit
    # Only allow applicants who have an ongoing application, or have pending application to submit.
    case applicant_status
      when :application_pending
        submission_for_stage_1
      when :ongoing
        send "submission_for_stage_#{current_stage_number}"
      else
        flash[:error] = t('batch_application.general.submission_failure')
        redirect_to apply_batch_path(batch: params[:batch])
    end
  end

  def prep_for_stage_1
    batch_application = BatchApplication.new
    @form = ApplicationStageOneForm.new(batch_application)
    @form.prepopulate! team_lead: current_batch_applicant
  end

  def submission_for_stage_1
    @skip_container = true
    batch_application = BatchApplication.new(
      team_lead: current_batch_applicant,
      batch: current_batch,
      application_stage: ApplicationStage.initial_stage
    )

    @form = ApplicationStageOneForm.new(batch_application)

    if @form.validate(params[:application_stage_one])
      @form.save
      redirect_to apply_batch_path(batch: params[:batch])
    else
      render 'batch_application/stage_1'
    end
  end

  def prep_for_stage_2
    application_submission = ApplicationSubmission.new
    @form = ApplicationStageTwoForm.new(application_submission)
  end

  def submission_for_stage_2
    application_submission = ApplicationSubmission.new(
      application_stage: current_stage,
      batch_application: current_application
    )

    @form = ApplicationStageTwoForm.new(application_submission)

    if @form.validate(params[:application_stage_two])
      @form.save
      redirect_to apply_batch_path(batch: params[:batch])
    else
      render 'batch_application/stage_2'
    end
  end

  def prep_for_stage_3
    # nothing to prepare here!
  end

  def prep_for_stage_4
  end

  def submission_for_stage_4
    # TODO: Server-side error handling for stage 4 inputs.

    # TODO: How to handle file uploads (if any for pre-selection)?
    current_application.application_submissions.create!(
      application_stage: current_stage
    )

    redirect_to apply_batch_path(batch: params[:batch])
  end

  def prep_for_stage_5
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
    render layout: 'application_v2'
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

      render 'batch_application/sign_in_email_sent', layout: 'application_v2'
    else
      # There's probably something wrong with the entered email address. Render the form again.
      render 'batch_application/identify', layout: 'application_v2'
    end
  end

  protected

  # Returns currently picked batch.
  def current_batch
    @current_batch ||= Batch.find_by(batch_number: params[:batch])
  end

  # Returns the application_stage that current batch is at.
  def current_stage
    @current_stage ||= current_batch&.application_stage
  end

  # Returns the stage number of current batch.
  def current_stage_number
    @current_stage_number ||= current_stage&.number.to_i
  end

  def applicant_stage
    @applicant_stage ||= begin
      if current_application.blank?
        ApplicationStage.find_by number: 1
      else
        current_application.application_stage
      end
    end
  end

  # Returns stage number of current applicant.
  def applicant_stage_number
    @applicant_stage_number ||= applicant_stage.number
  end

  # Returns batch application of current applicant.
  def current_application
    @current_application ||= current_batch_applicant&.batch_applications.find_by(batch: current_batch)
  end

  helper_method :current_batch
  helper_method :current_stage
  helper_method :current_application

  private

  def lock_under_feature_flag
    return if Rails.env.test?
    raise_not_found unless Feature.active?(:application_v2, current_founder)
  end

  def set_instance_variables
    @skip_container = true
    @hide_sign_in = true
  end

  # Returns one of :application_pending, :application_expired, :expired, :rejected, :submitted, or :ongoing, to indicate
  # which view should be rendered.
  #
  # Hari: I'm disabling complexity cops here, because the point of this method is to put the complex state logic in
  # one place. It used to be scattered across many methods, but that became unmanageable, and I had to bring it
  # together to make sense of it all.
  #
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  def applicant_status
    if current_application.blank?
      # There's no application...
      if current_stage_number == 1 || (current_stage_number == 2 && !stage_expired?)
        # ... and current stage is 1, or un-expired 2, then applications are still accepted.
        :application_pending
      else
        # ... but batch has moved to a stage where application is not possible.
        :application_expired
      end
    elsif applicant_stage_number == 1
      # There is an application, and applicant is still in stage 1...
      if current_stage_number == 1 || (current_stage_number == 2 && !stage_expired?)
        # ... and current stage is 1, or un-expired 2, then applications are still accepted.
        :payment_pending
      else
        # ... but batch has moved to a stage where application is not possible.
        :application_expired
      end
    elsif applicant_stage_number == current_stage_number
      # There is an application which is on batch's stage...
      if applicant_has_submitted?
        # ...and it has been submitted.
        :submitted
      else
        # ... and if stage's deadline has passed, then it's expired, otherwise ongoing.
        stage_expired? ? :expired : :ongoing
      end
    elsif applicant_stage_number > current_stage_number
      # The application has been selected for the next stage.
      :submitted
    else
      # Application has been left behind. If a submission exists for application's stage, then it was rejected,
      # otherwise it expired when the stage's deadline passed.
      applicant_has_submitted? ? :rejected : :expired
    end
  end

  def applicant_has_submitted?
    return true if applicant_stage_number == 1

    ApplicationSubmission.where(
      batch_application_id: current_application.id,
      application_stage_id: applicant_stage.id
    ).present?
  end

  # Batch's stage should have expired, and current stage should be same as application stage.
  def stage_expired?
    current_batch.stage_expired?
  end

  # Check whether a token parameter has been supplied. Sign in application founder if there's a corresponding entry.
  def check_token
    return if params[:token].blank?
    applicant = BatchApplicant.find_using_token params[:token]

    if applicant.blank?
      flash[:error] = "That token is invalid. It's likely that it has been used already. Please generate a new one-time link using the form on this page."
      return
    end

    # Sign in the current application founder.
    @current_batch_applicant = applicant

    # Store a cookie that'll keep him / her signed in for 2 months.
    cookies[:applicant_token] = { value: applicant.token, expires: 2.months.from_now }
  end

  # Redirect applicant to sign in page is zhe isn't signed in.
  def ensure_applicant_is_signed_in
    return if current_batch_applicant.present?
    redirect_to apply_identify_url(batch: params[:batch])
  end

  # Save the batch being requested in session. We'll add this info to the sign in link.
  def save_batch(batch)
    return if batch.blank?
    session[:application_batch] = batch
  end
end
