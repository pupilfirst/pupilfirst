class Payment < ApplicationRecord
  belongs_to :batch_application
  belongs_to :original_batch_application, class_name: 'BatchApplication'
  belongs_to :batch_applicant
  belongs_to :startup
  belongs_to :founder

  STATUS_REQUESTED = -'requested'
  STATUS_PAID = -'paid'
  STATUS_FAILED = -'failed'

  scope :requested, -> { where(instamojo_payment_request_status: payment_requested_statuses, instamojo_payment_status: nil, paid_at: nil) }
  scope :paid, -> { where.not(paid_at: nil) }

  def self.payment_requested_statuses
    [Instamojo::PAYMENT_REQUEST_STATUS_PENDING, Instamojo::PAYMENT_REQUEST_STATUS_SENT]
  end

  validate :must_have_batch_application
  validates :batch_applicant_id, presence: true

  def must_have_batch_application
    return if batch_application_id.present? || original_batch_application_id.present?
    errors[:base] << 'one of batch_application_id or original_batch_application_id must be present'
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
    return false if paid?
    instamojo_payment_request_status.in? Payment.payment_requested_statuses
  end

  # An payment is considered processed when instamojo payment status is credited.
  def paid?
    paid_at.present?
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

  def perform_post_payment_tasks!
    # Log payment time, if unrecorded.
    update!(paid_at: Time.now) if paid_at.blank?

    # update the team leads latest payment date
    batch_applicant.update!(latest_payment_at: paid_at)

    # mark the coupon applied, if any, as redeemed
    batch_application.latest_coupon.mark_redeemed!(batch_application) if batch_application.latest_coupon.present?

    # create a referral coupon for the current applicant
    batch_applicant.generate_referral_coupon!

    # initiate referral refund if current applicant was referred by someone
    BatchApplicants::ReferralRewardService.new(batch_applicant).execute if batch_applicant.referrer.present?

    # Let the batch application (if still linked) take care of its stuff.
    batch_application&.perform_post_payment_tasks!

    IntercomLastApplicantEventUpdateJob.perform_later(batch_applicant, 'payment_complete') unless Rails.env.test?
  end

  # Remove direct relation from application to payment and store the relationship as 'original batch application'
  def archive!
    self.original_batch_application_id = batch_application_id
    self.batch_application_id = nil
    save!
  end
end
