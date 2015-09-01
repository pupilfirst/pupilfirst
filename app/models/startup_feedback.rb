class StartupFeedback < ActiveRecord::Base
  belongs_to :startup
  attr_accessor :send_email

  before_save do
    if send_email == '1'
      # send email here
    end
  end
end
