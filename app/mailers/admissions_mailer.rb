# Mails sent out as part of the admissions process.
class AdmissionsMailer < ApplicationMailer
  def automatic_refund_failed(payment)
    @payment = payment
    mail(to: 'hosting@sv.co', subject: 'SV.CO: Automatic Refund Failed')
  end
end
