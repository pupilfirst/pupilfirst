module PublicSlack
  class PruneMembershipService
    include Loggable

    def execute
      return if expired_founders.blank?

      log 'Removing expired founders from all private groups on Public Slack...'
      private_groups.each { |group_id| remove_expired_founders(group_id) }
    end

    private

    # Returns an array of slack_user_ids for founders ready to be pruned.
    def expired_founders
      @expired_founders ||= begin
        latest_payments = Payment.paid.where.not(startup_id: nil).group(:startup_id).maximum(:billing_end_at)
        expired_startups = latest_payments.select do |_startup_id, billing_end_at|
          pruning_window_contains? billing_end_at
        end.keys
        # TODO: Handle founders without slack_user_id
        Founder.where(startup: expired_startups).pluck(:slack_user_id)
      end
    end

    # Boundaries of the pruning window. Modify this to change grace periods.
    def pruning_window_contains?(datetime)
      datetime.between?(4.days.ago.beginning_of_day, 4.days.ago.end_of_day)
    end

    def private_groups
      response = api.get('groups.list')
      response['groups'].map { |group| group.dig('id') }
    end

    def remove_expired_founders(group_id)
      expired_founders.each { |founder_slack_id| remove_from_group(group_id, founder_slack_id) }
    end

    def remove_from_group(group_id, founder_slack_id)
      return if founder_slack_id.blank?

      log "Removing founder #{founder_slack_id} from group #{group_id}"
      params = { channel: group_id, user: founder_slack_id }
      api.get('groups.kick', params: params)
    rescue PublicSlack::OperationFailureException => e
      raise e if e.parsed_response['error'] != 'not_in_group'
    end

    def api
      @api ||= begin
        app_token = Rails.application.secrets.slack.dig(:app, :oauth_token)
        PublicSlack::ApiService.new(token: app_token)
      end
    end
  end
end
