module OneOff
  # This one-off service is a simple modification of PublicSlack::PruneMembershipService. The pruning window has been replaced with a single expiration date threshold.
  class SlackMembershipPruningService
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
        expired_startups = candidate_payments.each_with_object([]) do |payment, startups_array|
          startups_array << payment.startup if payment.startup.active_payment == payment
        end

        Founder.where(startup: expired_startups).where.not(slack_user_id: nil)
      end
    end

    # All 'paid' payments which expired before 3 days.
    def candidate_payments
      Payment.paid.where('billing_end_at < ?', 4.days.ago.beginning_of_day)
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
