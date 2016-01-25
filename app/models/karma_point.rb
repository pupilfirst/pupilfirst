class KarmaPoint < ActiveRecord::Base
  belongs_to :user
  belongs_to :startup

  belongs_to :source, polymorphic: true

  validates_uniqueness_of :source_id, scope: [:source_type], allow_nil: true
  validates_presence_of :points

  validate :needs_startup_or_user

  def needs_startup_or_user
    if startup.blank? && user.blank?
      message = 'one of product or founder must be selected'
      errors.add :startup_id, message
      errors.add :user_id, message
    end
  end

  before_validation :assign_startup_for_user

  def assign_startup_for_user
    return if startup.present? || user.blank?
    self.startup_id = user.startup_id
  end
end
