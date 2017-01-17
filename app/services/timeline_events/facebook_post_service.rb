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
        log "Attempting to post #{@timeline_event.facebook_friendly_url} to #{founder.name}'s Facebook wall."
        result = facebook_client(founder).put_connections(:me, :feed, link: @timeline_event.facebook_friendly_url)
        log "Posted on #{founder.name}'s Facebook wall. Post id: #{result['id']}" if result['id'].present?
      else
        Founders::FacebookService.new(founder).disconnect!
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
  end
end
