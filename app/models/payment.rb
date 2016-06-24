class Payment < ActiveRecord::Base
  belongs_to :batch_application

  validates :batch_application_id, presence: true

  STATUS_REQUESTED = -'requested'
  STATUS_PAID = -'paid'
  STATUS_FAILED = -'failed'

  # Before an payment entry can be created, a request must be placed with Instamojo.
  after_create do
    raise 'Payment cannot be initialized without supplying a batch application.' if batch_application.blank?

    instamojo = Instamojo.new

    response = instamojo.create_payment_request(
      amount: batch_application.fee,
      buyer_name: batch_application.team_lead.name,
      email: batch_application.team_lead.email
    )

    self.amount = batch_application.fee
    self.instamojo_payment_request_id = response[:id]
    self.instamojo_payment_request_status = response[:status]
    self.short_url = response[:short_url]
    self.long_url = response[:long_url]

    save!
  end

  def status
    if paid?
      STATUS_PAID
    elsif failed?
      STATUS_FAILED
    elsif requested?
      STATUS_REQUESTED
    else
      raise "Unexpected state of payment. Please inspect Payment ##{id}."
    end
  end

  # A payment is considered requested when instamojo payment status is requested.
  def requested?
    instamojo_payment_request_status.in? [Instamojo::PAYMENT_REQUEST_STATUS_PENDING, Instamojo::PAYMENT_REQUEST_STATUS_SENT]
  end

  # An payment is considered processed when instamojo payment status is credited.
  def paid?
    instamojo_payment_status == Instamojo::PAYMENT_STATUS_CREDITED
  end

  # A payment has failed when instamojo payment status is failed.
  def failed?
    instamojo_payment_status == Instamojo::PAYMENT_STATUS_FAILED
  end

  def refresh_payment!(payment_id)
    # Store the payment ID.
    update!(instamojo_payment_id: payment_id)

    # Fetch latest payment status from Instamojo.
    instamojo = Instamojo.new
    response = instamojo.payment_details(payment_request_id: instamojo_payment_request_id, payment_id: payment_id)

    update!(
      instamojo_payment_request_status: response[:payment_request_status],
      instamojo_payment_status: response[:payment_status],
      fees: response[:fees]
    )
  end

  # Debug method. Use to pull latest payment details from Instamojo.
  def raw_details
    instamojo = Instamojo.new
    instamojo.raw_payment_request_details(instamojo_payment_request_id)
  end

  def peform_post_payment_tasks!
    # Log payment time, if unrecorded.
    update!(paid_at: Time.now) if paid_at.blank?

    # Let the batch application take care of its stuff.
    batch_application.peform_post_payment_tasks!
  end
end
