class Instamojo
  # Status values that we are concerned with:
  PAYMENT_REQUEST_STATUS_PENDING = -'Pending'
  PAYMENT_STATUS_CREDITED = -'Credit'
  PAYMENT_STATUS_FAILED = -'Failed'

  attr_accessor :payment_request_id

  def initialize(payment_request_id: nil)
    self.payment_request_id = payment_request_id
  end

  def create_payment_request(amount:, buyer_name:, email:)
    uri = URI(payment_request_endpoint)
    request = Net::HTTP::Post.new(uri)

    request.set_form_data payment_request_params(amount, buyer_name, email)
    request['X-Api-Key'] = api_key
    request['X-Auth-Token'] = auth_token

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    raw_response = http.request(request)

    # Parse the response
    response = JSON.parse(raw_response.body).with_indifferent_access

    raise 'Failed to create payment request. Please check.' unless response.key?(:success)

    payment_request = response[:payment_request]

    {
      id: payment_request[:id],
      status: payment_request[:status],
      short_url: payment_request[:shorturl],
      long_url: payment_request[:longurl]
    }
  end

  private

  def payment_request_params(amount, buyer_name, email)
    {
      purpose: 'Application to SV.CO',
      amount: amount.to_s,
      buyer_name: buyer_name,
      email: email,
      redirect_url: redirect_url,
      send_email: Rails.env.production?,
      send_sms: false,
      # webhook: webhook_url
    }
  end

  def redirect_url
    Rails.application.routes.url_helpers.batch_applications_redirect_url(source: 'instamojo')
  end

  def webhook_url
    Rails.application.routes.url_helpers.batch_applications_webhook_url(source: 'instamojo')
  end

  def base_url
    APP_CONFIG[:instamojo][:url]
  end

  def payment_request_endpoint
    [base_url, 'payment-requests/'].join('/')
  end

  def api_key
    APP_CONFIG[:instamojo][:api_key]
  end

  def auth_token
    APP_CONFIG[:instamojo][:auth_token]
  end

  def payment_status
    raise 'payment_request_id is missing. Did you forget to supply it, or create a payment request?' if payment_request_id.nil?

    raise NotImplementedError
  end
end
