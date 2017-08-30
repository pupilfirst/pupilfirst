module Founders
  class UpdateSlackNameService
    include Loggable

    def initialize(founder)
      @founder = founder
    end

    def execute
      return unless @founder.connected_to_slack?

      api.get('users.profile.set', params: params)

      log "Updated Slack profile (name) for Founder ##{@founder.id}"
    end

    private

    def api
      @api ||= PublicSlack::ApiService.new(token: @founder.slack_access_token)
    end

    def params
      {
        profile: {
          first_name: @founder.name,
          last_name: "(#{@founder.startup.product_name})"
        }.to_json
      }
    end
  end
end
