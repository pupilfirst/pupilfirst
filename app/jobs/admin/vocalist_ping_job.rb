module Admin
  # Used by admins to send vocalist pings to a variety of targets. Triggered in `VocalistPingForm`.
  class VocalistPingJob < ApplicationJob
    queue_as :low_priority

    def perform(message, recipient_type, recipient, admin_user, team_leads_only)
      @message = message
      @recipient_type = recipient_type
      @recipient = recipient
      @admin_user = admin_user
      @team_leads_only = (team_leads_only == '1')

      execute
    end

    def execute
      response = case @recipient_type
        when 'founders'
          ping_founders
        when 'startups'
          ping_startups
        when 'levels'
          ping_levels
        when 'channel'
          ping_channel
        else
          raise "Unexpected target_type encountered: #{@recipient_type}"
      end

      # Send email to admin with results.
      AdminUserMailer.vocalist_ping_results(@message, recipient_for_email, @admin_user, errors_for_email(response)).deliver_later
    end

    private

    def errors_for_email(response)
      return if response.errors.blank?

      CSV.generate do |csv|
        csv << ["Key", "Message", "Additional Info"]

        response.errors.each do |(key, value)|
          row = if key.is_a?(Integer)
            [key, value, Founder.find(key).name]
          else
            [key, value]
          end

          csv << row
        end
      end
    end

    def recipient_for_email
      case @recipient_type
        when 'founders'
          { 'founders' => Founder.find(@recipient).pluck(:name) }
        when 'startups'
          { startups: Startup.find(@recipient).pluck(:name), team_leads_only: @team_leads_only }
        when 'levels'
          { levels: Level.find(@recipient).pluck(:number), team_leads_only: @team_leads_only }
        when 'channel'
          { channel: @recipient }
        else
          raise "Unexpected target_type encountered: #{@recipient_type}"
      end
    end

    def ping_founders
      service.post message: @message, founders: Founder.find(@recipient)
    end

    def ping_startups
      founders = Founder.where(startup: @recipient)
      founders = founders.where(id: Startup.where(id: @recipient).select(:team_lead_id)) if @team_leads_only
      service.post message: @message, founders: founders
    end

    def ping_levels
      founders = Founder.joins(startup: :level).where(startups: { level: @recipient })
      founders = founders.where(id: Startup.select(:team_lead_id)) if @team_leads_only
      service.post message: @message, founders: founders
    end

    def ping_channel
      service.post message: @message, channel: @recipient
    end

    def service
      @service ||= PublicSlack::MessageService.new
    end
  end
end
