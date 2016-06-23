# encoding: utf-8

module BatchApplicationsHelper
  def next_stage_date
    current_stage.next.tentative_start_date(current_batch).strftime('%A, %b %e')
  end

  def payment_button_message(batch_application)
    batch_application.payment.present? ? t('batch_application.stage_1.payment_retry') : t('batch_application.stage_1.payment_start')
  end

  def applications_close_soon_message(batch)
    deadline = batch.application_stage_deadline.strftime('%d %b, %l:%M %p (%z)')
    delta = time_ago_in_words(batch.application_stage_deadline)
    t('batch_application.general.applications_close_soon_html', batch_number: batch.batch_number, deadline: deadline, delta: delta)
  end
end
