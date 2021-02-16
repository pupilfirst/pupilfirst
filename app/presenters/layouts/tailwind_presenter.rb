module Layouts
  class TailwindPresenter < ::ApplicationPresenter
    def meta_description
      @meta_description ||= SchoolString::Description.for(current_school)
    end

    def flash_messages
      view.flash.map do |type, message|
        {
          type: type,
          message: message
        }
      end.to_json
    end

    def vapid_public_key_bytes
      key = Rails.application.secrets.vapid_public_key

      raise 'A VAPID public key is required' if key.blank?

      Base64.urlsafe_decode64(key).bytes
    end

    def webpush_subscription_endpoint
      return if current_user&.webpush_subscription.blank?

      current_user.webpush_subscription['endpoint']
    end
  end
end
