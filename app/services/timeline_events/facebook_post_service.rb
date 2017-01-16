module TimelineEvents
  class FacebookPostService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def post
      @timeline_event.founder_event? ? post_to_founder(@timeline_event.founder) : post_to_all_founders(@timeline_event.startup)
    end

    private

    def post_to_founder(founder)
      if founder.facebook_connected?
        facebook_client(founder).put_connections(:me, :feed, link: @timeline_event.facebook_friendly_url)
      else
        Founders::FacebookService.new(founder).disconnect!
        # TODO: Probably send a vocalist ping informing missing facebook connection
        false
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
