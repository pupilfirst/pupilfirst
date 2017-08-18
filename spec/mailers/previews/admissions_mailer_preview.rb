class AdmissionsMailerPreview < ActionMailer::Preview
  def automatic_refund_failed
    founder = Founder.new(
      id: 1,
      name: 'John Doe',
      email: 'johndoe@example.com',
      phone: '9876543210'
    )

    payment = Payment.new(
      id: 1,
      founder: founder,
      amount: 4000.0
    )

    AdmissionsMailer.automatic_refund_failed(payment)
  end
end
