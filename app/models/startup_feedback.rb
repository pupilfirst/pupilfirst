class StartupFeedback < ActiveRecord::Base
  belongs_to :startup
  attr_accessor :send_email
end
