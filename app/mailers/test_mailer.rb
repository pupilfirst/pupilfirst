class TestMailer < ApplicationMailer
  layout 'mailer_v2'

  def test_mail(email_address)
    mail(to: email_address, subject: "Test Email")
  end
end
