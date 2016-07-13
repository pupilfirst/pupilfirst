class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'SV.CO <help@sv.co>'
  layout 'mailer'
end
