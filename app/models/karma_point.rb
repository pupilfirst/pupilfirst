class KarmaPoint < ActiveRecord::Base
  belongs_to :founder
  belongs_to :startup

  belongs_to :source, polymorphic: true

  validates_uniqueness_of :source_id, scope: [:source_type], allow_nil: true
  validates_presence_of :points

  validate :needs_startup_or_founder

  def needs_startup_or_founder
    if startup.blank? && founder.blank?
      message = 'one of product or founder must be selected'
      errors.add :startup_id, message
      errors.add :founder_id, message
    end
  end

  before_validation :assign_startup_for_founder

  def assign_startup_for_founder
    return if startup.present? || founder.blank?
    self.startup_id = founder.startup_id
  end

  # TODO: probably enable this after ensuring existing records are taken care of
  # validate :founder_present_if_private_event
  #
  # def founder_present_if_private_event
  #   return unless source.is_a? TimelineEvent
  #   errors.add :founder_id, 'a founder must be specified when the source is a private event' if source.private? && !founder.present?
  # end
end
