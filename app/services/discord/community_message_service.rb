module Discord
  class CommunityMessageService
    include RoutesResolvable
    def initialize(community)
      @community = community
    end

    def post_topic_created(topic)
      return if topic.blank?

      message =
        I18n.t(
          'services.discord.community_message_service.post_topic_created',
          user_name: topic.creator.name,
          topic_url: url_helpers.topic_url(topic, url_options),
          topic_title: topic.title
        )

      send_message(message)
    end

    private

    def send_message(message)
      if @community.discord_channel_id.blank? || !configuration.configured? ||
           message.blank? || message.length > 2000
        return
      end

      Discordrb::API::Channel.create_message(
        "Bot #{configuration.bot_token}",
        @community.discord_channel_id,
        message
      )
    rescue Discordrb::Errors::NoPermission
      Rails
        .logger.error "No permission to send message to channel #{@community.discord_channel_id}"
    rescue RestClient::BadRequest => e
      Rails
        .logger.error "Bad request with discord_channel_id: #{@community.discord_channel_id}; #{e.response.body}"
    end

    def url_options
      @url_options ||=
        { host: @community.school.domains.primary.fqdn, protocol: 'https' }
    end

    def configuration
      @configuration ||= Schools::Configuration::Discord.new(@community.school)
    end
  end
end
