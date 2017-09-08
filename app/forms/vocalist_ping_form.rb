class VocalistPingForm < Reform::Form
  property :channel
  property :levels
  property :startups
  property :team_leads_only
  property :founders
  property :message, validates: { presence: true }

  property :channel_options

  validate :at_least_one_target_present

  def at_least_one_target_present
    clean_up_targets
    return if channel.present? || startups.present? || founders.present? || levels.present?
    errors[:base] << 'Please select a channel OR one or more levels OR startups OR founders!'
  end

  def valid_channels
    @valid_channels ||= PublicSlack::MessageService.valid_channel_names
  end

  # rubocop:disable Metrics/AbcSize
  def send_pings
    service = PublicSlack::MessageService.new

    if founders.present?
      service.post message: message, founders: Founder.find(founders)
    elsif startups.present?
      founders = Founder.where(startup: startups)
      founders = founders.where(id: startups.pluck(:team_lead_id)) if team_leads_only == '1'
      service.post message: message, founders: founders
    elsif levels.present?
      founders = Founder.joins(startup: :level).where(startups: { level: levels })
      founders = founders.where(id: startups.pluck(:team_lead_id)) if team_leads_only == '1'
      service.post message: message, founders: founders
    else
      service.post message: message, channel: channel
    end
  end
  # rubocop:enable Metrics/AbcSize

  def clean_up_targets
    founders.reject!(&:empty?)
    startups.reject!(&:empty?)
    levels.reject!(&:empty?)
  end
end
