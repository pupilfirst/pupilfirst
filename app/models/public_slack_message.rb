class PublicSlackMessage < ActiveRecord::Base
  belongs_to :founder
  has_one :karma_point, as: :source

  has_many :reactions, class_name: PublicSlackMessage, foreign_key: 'reaction_to_id'
  belongs_to :reaction_to, class_name: PublicSlackMessage

  def reaction?
    reaction_to.present?
  end

  def reaction_details
    reaction_to_author = reaction_to.founder.present? ? reaction_to.founder.fullname : reaction_to.slack_username
    "reacted with #{body} to \'#{reaction_to.body}\' from #{reaction_to_author}"
  end

  def self.founders_active_last_hour
    Founder.where(id: PublicSlackMessage.where('created_at > ?', 1.hour.ago).select(:founder).distinct.pluck(:founder_id))
  end

  def self.available_channels
    all.pluck(:channel).uniq
  end
end
