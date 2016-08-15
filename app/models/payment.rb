class Payment < ActiveRecord::Base
  belongs_to :batch_application
  belongs_to :original_batch_application, class_name: 'BatchApplication'
  belongs_to :batch_applicant

  STATUS_REQUESTED = -'requested'
  STATUS_PAID = -'paid'
  STATUS_FAILED = -'failed'

  scope :requested, -> { where(instamojo_payment_request_status: payment_requested_statuses, instamojo_payment_status: nil) }
  scope :paid, -> { where(instamojo_payment_status: Instamojo::PAYMENT_STATUS_CREDITED) }

  def self.payment_requested_statuses
    [Instamojo::PAYMENT_REQUEST_STATUS_PENDING, Instamojo::PAYMENT_REQUEST_STATUS_SENT]
  end

  validate :must_have_batch_application

  def must_have_batch_application
    return if batch_application_id.present? || original_batch_application_id.present?
    errors[:base] << 'one of batch_application_id or original_batch_application_id must be present'
  end

  # Before an payment entry can be created, a request must be placed with Instamojo.
  before_create do
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
    instamojo_payment_request_status.in? Payment.payment_requested_statuses
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

  def perform_post_payment_tasks!
    # Log payment time, if unrecorded.
    update!(paid_at: Time.now) if paid_at.blank?

    # Let the batch application (if still linked) take care of its stuff.
    batch_application&.perform_post_payment_tasks!

    add_intercom_paid_applicant_tag if Rails.env.production?
  end

  # Remove direct relation from application to payment and store the relationship as 'original batch application'
  def archive!
    self.original_batch_application_id = batch_application_id
    self.batch_application_id = nil
    save!
  end

  def add_intercom_paid_applicant_tag
    # initialize a client
    intercom = Intercom::Client.new(app_id: ENV['INTERCOM_API_ID'], api_key: ENV['INTERCOM_API_KEY'])

    # TODO: Create an intercom user for applicant if he doesn't have one
    # try to find corresponding intercom user
    begin
      user = intercom.users.find(email: batch_applicant.email)
    rescue Intercom::ResourceNotFound
      user = intercom.users.create(email: batch_applicant.email, name: batch_applicant.name)
    end

    intercom.tags.tag(name: 'Paid Applicant', users: [{ email: user.email }])

  rescue
    # simply skip for now if anything goes wrong here
    return
  end
end
