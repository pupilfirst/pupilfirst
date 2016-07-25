class BatchApplicationController < ApplicationController
  before_action :ensure_applicant_is_signed_in, except: :index
  before_action :ensure_batch_active, except: :index
  before_action :ensure_accurate_stage_number, only: %w(form submit complete expired rejected)

  layout 'application_v2'

  # GET /apply
  def index
    # TODO: Redirect to stage routes if applicant + application exists.
    set_instance_variables
    @form = BatchApplicationForm.new(BatchApplication.new)
  end

  # POST /apply/register
  def register

  end

  # GET /apply/identify
  def identify
    check_token

    if current_batch_applicant.present?
      redirect_to apply_batch_path(batch_number: params[:batch_number], state: login_state)
      return
    end

    @skip_container = true
    @form = BatchApplicantSignupForm.new(BatchApplicant.new)
  end

  # POST /apply/send_sign_in_email
  def send_sign_in_email
    @skip_container = true

    @form = BatchApplicantSignupForm.new(BatchApplicant.new)

    if @form.validate(params[:batch_applicant_signup])
      @form.save(params[:batch_number])
      redirect_to apply_sign_in_email_sent_path(batch_number: params[:batch_number])
    else
      flash.now[:error] = 'Something went wrong. Please try again.'
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
  def continue
    # TODO: Check token.

    case applicant_status
      when :application_pending
        redirect_to apply_path
      when :form
        redirect_to apply_stage_path(stage_number: applicant_stage_number)
      when :expired
        redirect_to apply_stage_expired(stage_number: applicant_stage_number)
      when :rejected
        redirect_to apply_stage_rejected(stage_number: applicant_stage_number)
      when :complete
        redirect_to apply_stage_complete(stage_number: applicant_stage_number)
      else
        raise "Unexpected applicant_status: #{applicant_status}"
    end
  end

  # GET /apply/stage/:stage_number
  def form
    send "stage_#{applicant_stage_number}_form" rescue NoMethodError
  end

  # POST /apply/stage/:stage_number/submit
  def submit
    send "stage_#{applicant_stage_number}_submit" rescue NoMethodError
  end

  # GET /apply/stage/:stage_number/complete
  def complete
    send "stage_#{applicant_stage_number}_complete" rescue NoMethodError
  end

  # GET /apply/stage/:stage_number/expired
  def expired
    send "stage_#{applicant_stage_number}_expired" rescue NoMethodError
  end

  # GET /apply/stage/:stage_number/rejected
  def rejected
    send "stage_#{applicant_stage_number}_rejected" rescue NoMethodError
  end

  # GET /apply/:batch
  #
  # rubocop:disable Metrics/CyclomaticComplexity
  def apply
    set_instance_variables

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

  def prep_for_stage_1
    batch_application = BatchApplication.new
    @form = ApplicationStageOneForm.new(batch_application)
    @form.prepopulate! team_lead: current_batch_applicant
  end

  def stage_1_submit
    @skip_container = true
    batch_application = BatchApplication.new(
      team_lead: current_batch_applicant,
      batch: current_batch,
      application_stage: ApplicationStage.initial_stage
    )

    @form = ApplicationStageOneForm.new(batch_application)

    if @form.validate(params[:application_stage_one])
      @form.save
      redirect_to apply_batch_path(batch_number: params[:batch_number], state: 'payment_pending')
    else
      render 'batch_application/stage_1'
    end
  end

  def stage_2_form
    application_submission = ApplicationSubmission.new
    @form = ApplicationStageTwoForm.new(application_submission)
  end

  def stage_2_submit
    application_submission = ApplicationSubmission.new(
      application_stage: current_stage,
      batch_application: current_application
    )

    @form = ApplicationStageTwoForm.new(application_submission)

    if @form.validate(params[:application_stage_two])
      @form.save
      redirect_to apply_batch_path(batch_number: params[:batch_number], state: 'stage_2_submitted')
    else
      render 'batch_application/stage_2'
    end
  end

  def submission_for_stage_4
    # TODO: Server-side error handling for stage 4 inputs.

    # TODO: How to handle file uploads (if any for pre-selection)?
    current_application.application_submissions.create!(
      application_stage: current_stage
    )

    redirect_to apply_batch_path(batch_number: params[:batch_number], state: 'stage_4_submitted')
  end

  def prep_for_stage_5
  end

  # POST /apply/restart/:batch
  def restart
    # Only applications in stage 1 can restart.
    raise_not_found if applicant_stage_number != 1
    current_application&.restart!

    flash[:success] = 'Your previous application has been discarded.'

    redirect_to apply_batch_path(batch_number: params[:batch_number], state: 'restart')
  end

  protected

  # Returns currently active batch.
  def current_batch
    @current_batch ||= begin
      open = Batch.open_for_applications

      if open.any?
        open.first
      else
        ongoing = Batch.applications_ongoing
        ongoing.first if ongoing.any?
      end
    end
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
  helper_method :applicant_stage

  private

  def set_instance_variables
    @skip_container = true
    @hide_sign_in = true
  end

  def login_state
    cached_status = applicant_status

    case cached_status
      when :application_pending, :application_expired, :payment_pending
        cached_status.to_s
      else
        "stage_#{applicant_stage_number}_#{cached_status}"
    end
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
      flash.now[:error] = "That token is invalid. It's likely that an hour has passed since it was generated."
      return
    end

    # Sign in the current application founder.
    @current_batch_applicant = applicant

    # Store a cookie that'll keep him / her signed in for 3 months.
    cookies[:applicant_token] = { value: applicant.token, expires: 3.months.from_now }
  end

  # Redirect applicant to sign in page is zhe isn't signed in.
  def ensure_applicant_is_signed_in
    return if current_batch_applicant.present?
    redirect_to apply_identify_url(batch: params[:batch_number])
  end

  def ensure_batch_active
    raise_not_found if current_stage_number == 0
  end

  def ensure_accurate_stage_number
    raise_not_found if applicant_stage_number != params[:stage_number]
  end
end
