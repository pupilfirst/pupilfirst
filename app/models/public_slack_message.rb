class PublicSlackMessage < ActiveRecord::Base
  belongs_to :founder
  has_one :karma_point, as: :source

  has_many :reactions, class_name: PublicSlackMessage, foreign_key: 'reaction_to_id'
  belongs_to :reaction_to, class_name: PublicSlackMessage

  scope :from_batch, -> (batch) { where(founder_id: Founder.find_by_batch(batch)) }

  def reaction?
    reaction_to.present?
  end

  def self.available_channels
    all.pluck(:channel).uniq
  end
end
