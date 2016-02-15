class PublicSlackMessage < ActiveRecord::Base
  belongs_to :founder
  has_one :karma_point, as: :source

  def self.founders_active_last_hour
    Founder.where(id: PublicSlackMessage.where('created_at > ?', 1.hour.ago).select(:founder).distinct.pluck(:founder_id))
  end

  def self.available_channels
    all.pluck(:channel).uniq
  end
end
