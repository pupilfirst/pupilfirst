class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'SV App <no-reply@svlabs.in>'
  layout 'mailer'
end
