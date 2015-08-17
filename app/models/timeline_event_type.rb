class TimelineEventType < ActiveRecord::Base
  validates_presence_of :key, :title
  validates_uniqueness_of :key

  def sample
    sample_text.present? ? sample_text : 'What\'s been happening?'
  end
end
