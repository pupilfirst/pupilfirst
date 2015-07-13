class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'Startup Village <no-reply@sv.co>'
  layout 'mailer'
end
