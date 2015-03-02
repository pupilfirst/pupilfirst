class ApplicationMailer < ActionMailer::Base
  # include Roadie::Rails::Automatic
  include Roadie::Rails::Mailer
  default from: 'SV App <no-reply@svlabs.in>'
  layout 'mailer'
end
