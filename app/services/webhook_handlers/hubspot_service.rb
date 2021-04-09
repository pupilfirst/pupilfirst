module WebhookHandlers
  class HubspotService
    def execute(payload)
      payload
        .map{|p| convert_to_hash(p)}
        .each{|p| process(p)}
    end

    private

    def convert_to_hash(payload)
      Hash[payload.map { |k, v| [k.to_s.underscore.to_sym, v]}]
    end

    def process(payload)
      procesor = find_procesor(**payload)
      procesor.call(**payload)
    end

    def find_procesor(subscription_type:, property_name:, **_)
      subscription_type == 'contact.propertyChange' && property_name == 'mvp' ?
        ToggleMvpTag.new : NO_OP
    end

    NO_OP = ->(**_) {}

    class ToggleMvpTag
      def call(object_id:, property_value:, **_)
      end
    end
  end
end