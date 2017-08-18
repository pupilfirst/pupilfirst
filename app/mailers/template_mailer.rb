class TemplateMailer < ApplicationMailer
  layout 'mailer_v2'

  def template_mail(email_address)
    mail(to: email_address, subject: 'Template Email')
  end
end
