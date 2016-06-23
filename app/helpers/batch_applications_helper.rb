# encoding: utf-8

module BatchApplicationsHelper
  def next_stage_date
    current_stage.next.tentative_start_date(current_batch).strftime('%A, %b %e')
  end

  def payment_button_message(batch_application)
    batch_application.payment.present? ? t('batch_application.stage_1.payment_retry') : t('batch_application.stage_1.payment_start')
  end
end
