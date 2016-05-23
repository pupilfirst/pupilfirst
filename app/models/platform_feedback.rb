class PlatformFeedback < ActiveRecord::Base
  def self.types_of_feedback
    %w(Feature Suggestion Bug Other)
  end
end
