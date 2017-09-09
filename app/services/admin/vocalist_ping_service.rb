module Admin
  class VocalistPingService
    def initialize(message, target)
      @message = message
      @channel = target[:channel]
      @levels = target[:levels]
      @startups = target[:startups]
      @team_leads_only = target[:team_leads_only]
      @founders = target[:founder]
    end

    def execute
      if @founders.present?
        ping_founders
      elsif @startups.present?
        ping_startups
      elsif @levels.present?
        ping_levels
      else
        ping_channel
      end
    end

    private

    def ping_founders
      service.post message: @message, founders: Founder.find(@founders)
    end

    def ping_startups
      founders = Founder.where(startup: @startups)
      founders = founders.where(id: @startups.select(:team_lead_id)) if @team_leads_only == '1'
      service.post message: @message, founders: founders
    end

    def ping_levels
      founders = Founder.joins(startup: :level).where(startups: { level: @levels })
      founders = founders.where(id: Startup.select(:team_lead_id)) if @team_leads_only == '1'
      service.post message: @message, founders: founders
    end

    def ping_channel
      service.post message: @message, channel: @channel
    end

    def service
      @service ||= PublicSlack::MessageService.new
    end
  end
end
