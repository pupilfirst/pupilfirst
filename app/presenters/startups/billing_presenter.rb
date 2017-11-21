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

    def subscription_notice_class
      subscription_end_date > 5.days.from_now ? 'subscription-notice__text' : 'subscription-notice__text--danger'
    end

    private

    def subscription_end_date
      @subscription_end_date ||= @startup.subscription_end_date
    end
  end
end
