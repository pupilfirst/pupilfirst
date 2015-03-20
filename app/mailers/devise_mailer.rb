# Devise's user notification mailer
#
# We override this class in order to use our custom mail layout.
class DeviseMailer < Devise::Mailer
  include Roadie::Rails::Automatic
  include Devise::Controllers::UrlHelpers

  default from: 'Startup Village <no-reply@svlabs.in>', bcc: 'outgoing@svlabs.in'
end
