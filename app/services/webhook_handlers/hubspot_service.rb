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
      MVP = 'mvp'

      def initialize(hubspot = Rails.configuration.hubspot_adapter)
        @hubspot = hubspot
      end

      def call(object_id:, property_value:, **_)
        toggle = ActiveModel::Type::Boolean.new.cast(property_value)
        email = @hubspot.fetch_contact_email(object_id)

        user = User.find_by(email: email)
        return unless user

        toggle ? add_tag(user) : remove_tag(user)
        user.save!
      end

      private

      def add_tag(user)
        user.tag_list.add(MVP)
        unless MVP.in?(user.school.user_tag_list)
          user.school.user_tag_list.add(MVP)
          user.school.save!
        end
      end

      def remove_tag(user)
        user.tag_list.remove(MVP)
        unless any_other_mvp_user?(user)
          user.school.user_tag_list.remove(MVP)
          user.school.save!
        end
      end

      def any_other_mvp_user?(user)
        User.where(school: user.school).where.not(id: user.id).tagged_with(MVP).exists?
      end
    end
  end
end