module Startups
  class BillingPresenter < ApplicationPresenter
    def initialize(view_context, startup)
      @startup = startup
      super(view_context)
    end

    def subscription_notice_text
      date = subscription_end_date.strftime('%b %d, %Y')
      if subscription_end_date.past?
        I18n.t('presenters.startups.billing.subscription_notice.expired', date: date)
      elsif subscription_end_date < 5.days.from_now
        I18n.t('presenters.startups.billing.subscription_notice.expiring_soon', date: date)
      else
        I18n.t('presenters.startups.billing.subscription_notice.active', date: date)
      end.html_safe
    end

    def subscription_notice_danger_class
      'subscription-notice__text--danger' if subscription_end_date < 5.days.from_now
    end

    def payment_history
      @startup.payments.paid.order('billing_end_at DESC').map do |payment|
        {
          date: payment.paid_at&.strftime('%d/%m/%Y'),
          start: payment.billing_start_at&.strftime('%b %d, %Y'),
          end: payment.billing_end_at&.strftime('%b %d, %Y'),
          amount: (payment.amount.present? ? '&#8377;' + payment.amount.to_s : 'N/A').html_safe,
          payee: payment.founder&.name
        }
      end
    end

    private

    def subscription_end_date
      @subscription_end_date ||= @startup.subscription_end_date
    end
  end
end
