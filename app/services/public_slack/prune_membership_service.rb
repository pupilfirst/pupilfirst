module PublicSlack
  class PruneMembershipService
    include Loggable

    def initialize
      @pruned_founders = []
    end

    def execute
      return if expired_founders.blank?

      log 'Removing expired founders from all private groups on Public Slack...'
      private_groups.each { |group_id| remove_expired_founders(group_id) }
      @pruned_founders.each { |founder| FounderMailer.slack_removal(founder).deliver_later }
    end

    private

    # Returns founders ready to be pruned.
    def expired_founders
      @expired_founders ||= begin
        latest_payments = Payment.paid.where.not(startup_id: nil).group(:startup_id).maximum(:billing_end_at)
        expired_startups = latest_payments.select do |_startup_id, billing_end_at|
          pruning_window_contains? billing_end_at
        end.keys
        Founder.where(startup: expired_startups).where.not(slack_user_id: nil)
      end
    end

    # Boundaries of the pruning window. Modify this to change grace periods.
    def pruning_window_contains?(datetime)
      datetime.between?(4.days.ago.beginning_of_day, 4.days.ago.end_of_day)
    end

    # Retrieve list of private groups and return an array of their group ids.
    def private_groups
      response = api.get('groups.list')
      response['groups'].map { |group| group.dig('id') }
    end

    def remove_expired_founders(group_id)
      expired_founders.each { |founder| remove_from_group(group_id, founder) }
    end

    def remove_from_group(group_id, founder)
      log "Removing founder #{founder.name} from group #{group_id}"
      params = { channel: group_id, user: founder.slack_user_id }
      response = api.get('groups.kick', params: params)
      @pruned_founders |= [founder] if response['ok']
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
