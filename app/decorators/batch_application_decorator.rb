class BatchApplicationDecorator < Draper::Decorator
  delegate_all

  def form
    @form ||= begin
      form = BatchApplications::RegistrationForm.new(BatchApplicant.new)
      form.prepopulate!(h.current_batch_applicant)
      form
    end
  end

  def old_applications(applicant)
    return [] if applicant.nil? || applicant.batch_applications.blank?

    applications = applicant.batch_applications.select do |application|
      application.status.in? [:expired, :complete, :rejected]
    end

    applications.map { |application| BatchApplicationDecorator.decorate(application) }
  end

  def applications_open?
    Batch.open_for_applications.any?
  end

  def certificate_background_image_base64
    APP_CONSTANTS[:certificate_background_base64]
  end

  def team_member_names
    batch_applicants.pluck(:name).sort
  end

  def preliminary_result
    application_stage.number > 2 ? 'Selected for Interview' : 'Not Selected'
  end

  def percentile_code_score
    grade[:code]&.round(1) || 'Not Available'
  end

  def percentile_video_score
    grade[:video]&.round(1) || 'Not Available'
  end

  def overall_percentile
    @overall_percentile ||= grading_service.overall_percentile&.round(1)
  end

  # used in stage4.html.slim
  def batch_start_date
    application_round.batch.start_date.strftime('%B %d, %Y')
  end

  # used to display submission deadline in stage4.html.slim
  def document_submission_deadline
    batch.batch_stages.where(application_stage: ApplicationStage.shortlist_stage).first.ends_at.strftime('%B %d, %Y')
  end

  # used to display interview feedback in stage_3_rejected.html.slim
  def interview_feedback
    application_submissions.where(application_stage: ApplicationStage.interview_stage).last&.feedback_for_team
  end

  def founders_profiles_complete?
    batch_applicants.all?(&:profile_complete?)
  end

  def next_stage_date
    target_stage = if model.status == :promoted
      application_stage
    else
      application_stage.next
    end

    application_round.round_stages.find_by(application_stage: target_stage).starts_at.strftime('%A, %b %e')
  end

  def url_entry_class(name)
    name = name.downcase

    if 'code'.in? name
      'testing-stage-complete__link-wrapper--code'
    elsif 'video'.in? name
      'testing-stage-complete__link-wrapper--video'
    elsif 'web'.in? name
      'testing-stage-complete__link-wrapper--website'
    elsif 'app'.in? name
      'testing-stage-complete__link-wrapper--application'
    else
      'testing-stage-complete__link-wrapper--default'
    end
  end

  def pretty_stage_status(stage_number)
    status = stage_status_service.status(stage_number)

    if status == :ongoing
      "Ends on #{stage_deadline.strftime('%b %d')}"
    else
      status.to_s.tr('_', ' ').capitalize
    end
  end

  def pretty_stage_deadline
    stage_deadline.strftime('%b %d')
  end

  # Used to determine which stage applicant is in for the progress bar.
  def stage_active_class(stage_number)
    base_class = stage_status_service.status(stage_number).to_s
    expected_stage_number = (status == :promoted ? application_stage.number - 1 : application_stage.number)
    expected_stage_number == stage_number ? base_class + ' applicant-stage' : base_class
  end

  def payment_button_message
    payment.present? ? h.t('batch_application.stage_1.payment_retry') : h.t('batch_application.stage_1.payment_start')
  end

  def closes_soon_message
    deadline = stage_deadline.strftime('%d %b, %l:%M %p (%z)')
    delta = time_ago_in_words(stage_deadline)
    t('batch_application.general.applications_close_soon_html', batch_number: application_round.batch.batch_number, deadline: deadline, delta: delta)
  end

  alias partnership_deed_ready? founders_profiles_complete?
  alias incubation_agreement_ready? founders_profiles_complete?

  private

  def stage_status_service
    @stage_status_service ||= BatchApplications::StageStatusService.new(model)
  end

  def grading_service
    BatchApplicationGradingService.new(model)
  end

  def grade
    @grade ||= grading_service.grade
  end
end
