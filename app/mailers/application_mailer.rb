class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'Startup Village <no-reply@svlabs.in>', bcc: 'outgoing@svlabs.in'
  layout 'mailer'
end
