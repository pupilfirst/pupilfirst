class VocalistPingForm < Reform::Form
  property :channel
  property :levels
  property :startups
  property :founders
  property :message, validates: { presence: true }

  validate :one_and_only_one_recipient_must_be_present

  def queue_pings(admin_user)
    recipient = [channel, startups, founders, levels].find(&:present?)
    Admin::VocalistPingJob.perform_later(message, recipient_type, recipient, admin_user)
  end

  def valid_channels
    @valid_channels ||= PublicSlack::MessageService.new.valid_channel_names
  end

  private

  def one_and_only_one_recipient_must_be_present
    clean_up_recipients
    return if [channel.present?, startups.present?, founders.present?, levels.present?].one?

    errors[:base] << 'Please select a channel, some levels, some startups, or some founders. Only one option is allowed.'
  end

  def recipient_type
    if founders.present?
      'founders'
    elsif startups.present?
      'startups'
    elsif levels.present?
      'levels'
    else
      'channel'
    end
  end

  def clean_up_recipients
    founders.reject!(&:empty?)
    startups.reject!(&:empty?)
    levels.reject!(&:empty?)
  end
end
