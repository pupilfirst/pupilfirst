class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'SV App <no-reply@svlabs.in>', bcc: 'outgoing@svlabs.in'
  layout 'mailer'
end
