# Creates a payment entry after contacting Instamojo API.
#
# Specifics of how this works can be controlled using options.
class PaymentCreateService
  def initialize(batch_application, skip_instamojo: false, skip_payment: false)
    @batch_application = batch_application
    @skip_instamojo = skip_instamojo
    @skip_payment = skip_payment
  end

  def execute
    payment = Payment.new(
      batch_application: @batch_application,
      batch_applicant: @batch_application.team_lead
    )

    unless @skip_payment || @skip_instamojo
      response = create_instamojo_payment_request

      payment.amount = @batch_application.fee
      payment.instamojo_payment_request_id = response[:id]
      payment.instamojo_payment_request_status = response[:status]
      payment.short_url = response[:short_url]
      payment.long_url = response[:long_url]
    end

    if @skip_payment
      payment.paid_at = Time.now
      payment.notes = 'Payment has been skipped.'
    end

    payment.save!

    # Return the payment
    payment
  end

  private

  def instamojo
    @instamojo ||= Instamojo.new
  end

  def create_instamojo_payment_request
    instamojo.create_payment_request(
      amount: @batch_application.fee,
      buyer_name: @batch_application.team_lead.name,
      email: @batch_application.team_lead.email
    )
  end
end
