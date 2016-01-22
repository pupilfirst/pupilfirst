class KarmaPoint < ActiveRecord::Base
  belongs_to :user
  belongs_to :startup

  belongs_to :source, polymorphic: true

  validates_uniqueness_of :source_id, scope: [:source_type], allow_nil: true
  validates_presence_of :startup_id, :points

  before_validation :assign_startup_for_user

  def assign_startup_for_user
    return if startup.present?
    self.startup = user.startup
  end
end
