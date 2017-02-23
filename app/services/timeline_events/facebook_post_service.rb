module TimelineEvents
  class FacebookPostService
    include Loggable

    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def post
      return false if @timeline_event.founder_event?

      post_to_all_founders(@timeline_event.startup)
      true
    end

    private

    def post_to_founder(founder)
      if founder.facebook_token_valid?
        log "Attempting to post #{@timeline_event.share_url} to #{founder.name}'s Facebook wall."

        begin
          result = facebook_client(founder).put_connections(:me, :feed, link: @timeline_event.share_url)
          log "Posted on #{founder.name}'s Facebook wall. Post id: #{result['id']}" if result['id'].present?
        rescue Koala::Facebook::ClientError => e
          handle_client_error(founder, e.message)
        end
      else
        disconnect(founder)
        # TODO: Probably send a vocalist ping informing missing facebook connection
      end
    end

    def post_to_all_founders(startup)
      startup.founders.each do |founder|
        post_to_founder(founder)
      end
    end

    def facebook_client(founder)
      Koala::Facebook::API.new(founder.fb_access_token)
    end

    def handle_client_error(founder, message)
      log "Failed to post to #{founder.name}'s Facebook wall. Error message follows: #{message}"
      log "Disconnecting Founder##{founder.id} #{founder.name}..."
      disconnect(founder)
    end

    def disconnect(founder)
      Founders::FacebookService.new(founder).disconnect!
    end
  end
end
