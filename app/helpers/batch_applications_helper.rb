# encoding: utf-8

module BatchApplicationsHelper
  def next_stage_date
    current_batch.next_stage_starts_on.strftime('%A, %b %e')
  end

  def payment_button_message(batch_application)
    batch_application.payment.present? ? t('batch_application.stage_1.payment_retry') : t('batch_application.stage_1.payment_start')
  end

  def applications_close_soon_message(batch)
    deadline = batch.application_stage_deadline.strftime('%d %b, %l:%M %p (%z)')
    delta = time_ago_in_words(batch.application_stage_deadline)
    t('batch_application.general.applications_close_soon_html', batch_number: batch.batch_number, deadline: deadline, delta: delta)
  end

  # Used to determine which stage applicant is in for the progress bar.
  def stage_active_class(stage_number)
    applicant_stage_number == stage_number ? 'applicant-stage' : ''
  end

  # Used to determine the status of a stage in the progress bar. Returns one of :pending, :ongoing, :complete,
  # :expired, :rejected, or :not_applicable
  #
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def stage_status(stage_number)
    if stage_number == applicant_stage_number
      if applicant_stage_number == current_stage.number
        applicant_status
      elsif applicant_stage_number > current_stage.number
        :pending
      elsif current_stage.number == 2
        applicant_status
      else
        :expired
      end
    elsif stage_number < applicant_stage_number
      :complete
    elsif applicant_status.in? [:ongoing, :complete]
      :pending
    else
      :not_applicable
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
    current_batch.application_stage_deadline.strftime('%b %d')
  end

  def stage_2_submission
    @stage_2_submission ||= begin
      ApplicationSubmission.where(
        batch_application_id: current_application.id,
        application_stage_id: applicant_stage.id
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
