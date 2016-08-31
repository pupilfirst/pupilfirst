class VocalistPingForm < Reform::Form
  property :channel, virtual: true
  property :startups, virtual: true
  property :founders, virtual: true
  property :message, virtual: true, validates: { presence: true }

  property :channel_options

  validate :atleast_one_target_present

  def atleast_one_target_present
    clean_up_targets
    return if channel.present? || startups.present? || founders.present?
    errors[:base] << 'Please select a channel OR one or more startups OR founders!'
  end

  def valid_channels
    @valid_channels ||= PublicSlackTalk.valid_channel_names
  end

  def send_pings
    if founders.present?
      PublicSlackTalk.post_message message: message, founders: Founder.find(founders)
    elsif startups.present?
      PublicSlackTalk.post_message message: message, founders: Founder.where(startup: startups)
    else
      PublicSlackTalk.post_message message: message, channel: channel
    end
  end

  def clean_up_targets
    founders.reject!(&:empty?)
    startups.reject!(&:empty?)
  end
end
