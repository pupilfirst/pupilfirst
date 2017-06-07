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
    @valid_channels ||= PublicSlackTalk.valid_channel_names
  end

  def send_pings
    if founders.present?
      PublicSlackTalk.post_message message: message, founders: Founder.find(founders)
    elsif startups.present?
      founders = Founder.where(startup: startups)
      founders = founders.where(startup_admin: true) if team_leads_only == '1'
      PublicSlackTalk.post_message message: message, founders: founders
    elsif levels.present?
      founders = Founder.joins(startup: :level).where(startups: { level: levels })
      founders = founders.where(startup_admin: true) if team_leads_only == '1'
      PublicSlackTalk.post_message message: message, founders: founders
    else
      PublicSlackTalk.post_message message: message, channel: channel
    end
  end

  def clean_up_targets
    founders.reject!(&:empty?)
    startups.reject!(&:empty?)
    levels.reject!(&:empty?)
  end
end
