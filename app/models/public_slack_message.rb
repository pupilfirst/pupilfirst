class PublicSlackMessage < ApplicationRecord
  belongs_to :founder, optional: true

  has_many :reactions, class_name: 'PublicSlackMessage', foreign_key: 'reaction_to_id', inverse_of: :reaction_to, dependent: :destroy
  belongs_to :reaction_to, class_name: 'PublicSlackMessage', optional: true

  scope :last_week, -> { where('created_at > ?', 1.week.ago.beginning_of_day) }

  def reaction?
    reaction_to.present?
  end

  def self.available_channels
    all.pluck(:channel).uniq
  end
end
