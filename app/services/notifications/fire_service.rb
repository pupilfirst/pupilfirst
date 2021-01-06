module Notifications
  class FireService
    def initialize(notification)
      @notification = notification
    end

    def fire
      Webpush.payload_send(
        message: JSON.generate(message),
        endpoint: @notification.recipient.web_push_subscription['endpoint'],
        p256dh: @notification.recipient.web_push_subscription['p256dh'],
        auth: @notification.recipient.web_push_subscription['auth'],
        vapid: vapid_keys,
        ssl_timeout: 5,
        open_timeout: 5,
        read_timeout: 5
      )
    end

    private

    def vapid_keys
      {
        subject: 'mailto:sender@example.com',
        public_key: Rails.application.secrets.vapid_public_key,
        private_key: Rails.application.secrets.vapid_private_key
      }
    end

    def message
      { title: @notification.message,
        icon: "/favicon.ico",
        tag: @notification.event
      }
    end
  end
end
