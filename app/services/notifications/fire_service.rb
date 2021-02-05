module Notifications
  class FireService
    def initialize(notification)
      @notification = notification
    end

    def fire
      return if @notification.blank?

      return if @notification.recipient.webpush_subscription.blank?

      begin
        Webpush.payload_send(
          message: JSON.generate(message),
          endpoint: @notification.recipient.webpush_subscription['endpoint'],
          p256dh: @notification.recipient.webpush_subscription['p256dh'],
          auth: @notification.recipient.webpush_subscription['auth'],
          vapid: vapid_keys,
          ssl_timeout: 5,
          open_timeout: 5,
          read_timeout: 5
        )
      rescue Webpush::InvalidSubscription, Webpush::ExpiredSubscription, Webpush::Unauthorized
        @notification.recipient.update!(webpush_subscription: {})
      end
    end

    private

    def vapid_keys
      {
        subject: 'mailto:support@pupilfirst.org',
        public_key: Rails.application.secrets.vapid_public_key,
        private_key: Rails.application.secrets.vapid_private_key
      }
    end

    def message
      { title: @notification.message,
        icon: "/favicon.ico",
        tag: @notification.id,
      }
    end
  end
end
