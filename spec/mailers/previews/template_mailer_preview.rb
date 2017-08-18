class TemplateMailerPreview < ActionMailer::Preview
  def template_mail
    TemplateMailer.template_mail('template@example.com')
  end
end
