# encoding: utf-8

module BatchApplicationsHelper
  def next_stage_date
    current_batch.next_stage_starts_on.strftime('%A, %b %e')
  end

  def payment_button_message(batch_application)
    batch_application.payment.present? ? t('batch_application.stage_1.payment_retry') : t('batch_application.stage_1.payment_start')
  end

  def applications_close_soon_message(batch)
    deadline = deadline_time.strftime('%d %b, %l:%M %p (%z)')
    delta = time_ago_in_words(deadline_time)
    t('batch_application.general.applications_close_soon_html', batch_number: batch.batch_number, deadline: deadline, delta: delta)
  end

  # Used to determine which stage applicant is in for the progress bar.
  def stage_active_class(stage_number)
    application_stage_number == stage_number ? 'applicant-stage' : ''
  end

  # Used to determine the status of a stage in the progress bar. Returns one of :pending, :ongoing, :complete,
  # :expired, :rejected, or :not_applicable
  #
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def stage_status(stage_number)
    if stage_number == application_stage_number
      application_status
    elsif stage_number < application_stage_number
      :complete
    else
      (application_status.in? [:ongoing, :complete]) ? :pending : :not_applicable
    end
  end

  def pretty_stage_status(stage_number)
    if stage_status(stage_number) == :ongoing
      "Ends on #{stage_deadline}"
    else
      stage_status(stage_number).to_s.tr('_', ' ').capitalize
    end
  end

  def stage_deadline
    deadline_time.strftime('%b %d')
  end

  def deadline_time
    current_batch.batch_stages.find_by(application_stage: application_stage).ends_at
  end

  def stage_2_submission
    @stage_2_submission ||= begin
      ApplicationSubmission.where(
        batch_application_id: current_application.id,
        application_stage: ApplicationStage.find_by(number: 2)
      ).first
    end
  end

  def url_entry_class(name)
    name = name.downcase
    if 'code'.in? name
      'icon-code'
    elsif 'video'.in? name
      'icon-video'
    elsif 'web'.in? name
      'icon-website'
    elsif 'app'.in? name
      'icon-application'
    else
      'icon-default'
    end
  end
end
