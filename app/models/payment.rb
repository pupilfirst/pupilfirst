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
    if instamojo_payment_status == Instamojo::PAYMENT_STATUS_CREDITED
      STATUS_PAID
    elsif instamojo_payment_status == Instamojo::PAYMENT_STATUS_FAILED
      STATUS_FAILED
    elsif instamojo_payment_request_status == Instamojo::PAYMENT_REQUEST_STATUS_PENDING
      STATUS_REQUESTED
    else
      raise "Unexpected state of payment. Please inspect Payment ##{id}."
    end
  end

  def paid?
    status == STATUS_PAID
  end
end
