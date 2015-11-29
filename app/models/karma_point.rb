class KarmaPoint < ActiveRecord::Base
  belongs_to :user
  delegate :startup, to: :user
  belongs_to :source, polymorphic: true

  validates_uniqueness_of :source_id, scope: [:source_type], allow_nil: true
end
