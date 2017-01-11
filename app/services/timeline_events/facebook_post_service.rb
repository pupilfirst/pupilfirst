module TimelineEvents
  class FacebookPostService
    def initialize(timeline_event)
      @timeline_event = timeline_event.decorate
      @founder = timeline_event.founder
    end

    def post
      return unless @founder.present?

      if @founder.facebook_connected?
        post_to_facebook
      else
        reset_facebook_connection
      end
    end

    private

    def post_to_facebook
      facebook_client.put_connections(:me, :feed, link: @timeline_event.facebook_friendly_url)
    end

    def reset_facebook_connection
      Founders::FacebookService.new(@founder).disconnect!
      # TODO: Probably send a vocalist ping informing missing facebook connection
      false
    end

    def facebook_client
      Koala::Facebook::API.new(@founder.fb_access_token)
    end
  end
end
