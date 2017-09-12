class VocalistPingForm < Reform::Form
  property :channel
  property :levels
  property :startups
  property :team_leads_only
  property :founders
  property :message, validates: { presence: true }

  validate :one_and_only_one_target_must_be_present

  def one_and_only_one_target_must_be_present
    clean_up_targets
    return if [channel.present?, startups.present?, founders.present?, levels.present?].one?
    errors[:base] << 'Please select a channel, some levels, some startups, or some founders. Only one option is allowed.'
  end

  def valid_channels
    @valid_channels ||= PublicSlack::MessageService.valid_channel_names
  end

  def send_pings
    target = {
      channel: channel,
      levels: levels,
      startups: startups,
      team_leads_only: team_leads_only,
      founders: founders
    }

    Admin::VocalistPingService.new(message, target).execute
  end

  def clean_up_targets
    founders.reject!(&:empty?)
    startups.reject!(&:empty?)
    levels.reject!(&:empty?)
  end
end
