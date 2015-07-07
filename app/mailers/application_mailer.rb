class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'Startup Village <no-reply@sv.co>', bcc: 'outgoing@svlabs.in'
  layout 'mailer'
end
