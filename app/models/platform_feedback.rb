class PlatformFeedback < ActiveRecord::Base
  belongs_to :founder
  has_one :karma_point, as: :source

  def self.types_of_feedback
    %w(Feature Suggestion Bug Other)
  end
end
