# Devise's user notification mailer
#
# We override this class in order to use our custom mail layout.
class DeviseMailer < Devise::Mailer
  include Roadie::Rails::Automatic
  include Devise::Controllers::UrlHelpers

  default from: "<#{Rails.application.secrets.default_sender_email_address}>"
end
