class Payment < ActiveRecord::Base
  belongs_to :batch_application
  has_and_belongs_to_many :batch_applicants

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
    instamojo_payment_request_status == Instamojo::PAYMENT_REQUEST_STATUS_PENDING
  end

  # An payment is considered processed when instamojo payment status is credited.
  def paid?
    instamojo_payment_status == Instamojo::PAYMENT_STATUS_CREDITED
  end

  # A payment has failed when instamojo payment status is failed.
  def failed?
    instamojo_payment_status == Instamojo::PAYMENT_STATUS_FAILED
  end
end
