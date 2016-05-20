# Mails sent out from the contact form.
class BatchApplicantMailer < ApplicationMailer
  # Since there's no DB table supporting ContactForm, this method accepts all data (to allow serialization).
  def sign_in(email, token, batch)
    @token = token
    @batch = batch
    mail(to: email, subject: 'Sign in to SV.CO')
  end
end
