class Payment < ApplicationRecord
  belongs_to :original_startup, class_name: 'Startup', optional: true
  belongs_to :startup, optional: true
  belongs_to :founder, optional: true

  STATUS_REQUESTED = -'requested'
  STATUS_PAID = -'paid'
  STATUS_FAILED = -'failed'
  STATUS_NOT_REQUESTED = -'not_requested'

  TYPE_ADMISSION = -'admission'
  TYPE_RENEWAL = -'renewal'

  def self.valid_payment_types
    [TYPE_ADMISSION, TYPE_RENEWAL]
  end

  validates :payment_type, inclusion: valid_payment_types, allow_nil: true
  validates :payment_type, presence: true, if: proc { |payment| payment.paid_at.present? }

  scope :pending, -> { where(paid_at: nil) }
  scope :requested, -> { pending.where(instamojo_payment_request_status: payment_requested_statuses, instamojo_payment_status: nil) }
  scope :paid, -> { where.not(paid_at: nil) }

  def self.payment_requested_statuses
    [Instamojo::PAYMENT_REQUEST_STATUS_PENDING, Instamojo::PAYMENT_REQUEST_STATUS_SENT]
  end

  def status
    if paid?
      STATUS_PAID
    elsif failed?
      STATUS_FAILED
    elsif requested?
      STATUS_REQUESTED
    elsif not_requested?
      STATUS_NOT_REQUESTED
    else
      raise "Unexpected state of payment. Please inspect Payment ##{id}."
    end
  end

  # A payment is considered requested when instamojo payment status is requested.
  def requested?
    return false if paid?
    instamojo_payment_request_status.in? Payment.payment_requested_statuses
  end

  # A payment is considered paid when the paid_at time is set.
  def paid?
    paid_at.present?
  end

  def not_requested?
    instamojo_payment_request_status.blank?
  end

  # A payment has failed when instamojo payment status is failed.
  def failed?
    instamojo_payment_status == Instamojo::PAYMENT_STATUS_FAILED
  end

  # A payment is refundable if it is younger than a week, and it was registered as paid by Instamojo.
  def refundable?
    return false unless paid?
    credited? && paid_at >= 1.week.ago
  end

  # A payment is credited (money received) only if Instamojo reports it as such.
  def credited?
    instamojo_payment_status == Instamojo::PAYMENT_STATUS_CREDITED
  end

  def refresh_payment!(payment_id)
    # Fetch latest payment status from Instamojo.
    instamojo = Instamojo.new
    response = instamojo.payment_details(payment_request_id: instamojo_payment_request_id, payment_id: payment_id)

    # Store the payment ID and returned attributes.
    update!(
      instamojo_payment_id: payment_id,
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

  # Remove direct relation from startup to payment and store the relationship as 'original startup'
  def archive!
    self.original_startup_id = startup_id
    self.startup_id = nil
    save!
  end

  def days_to_expiry
    return if billing_end_at.blank?
    ((billing_end_at - Time.now) / 1.day.to_f).ceil
  end
end
