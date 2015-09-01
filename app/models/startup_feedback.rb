class StartupFeedback < ActiveRecord::Base
  belongs_to :startup
  attr_accessor :send_email

  before_save do
    if send_email == '1' && !send_at.present?
      send_at = Time.now
      StartupMailer.feedback_as_email(self).deliver_later
    end
  end
end
