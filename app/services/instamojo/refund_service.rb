class Instamojo
  # Raised if an invalid type value is supplied to #create.
  InvalidTypeException = Class.new(StandardError)

  # Used to manage refund requests with Instamojo.
  class RefundService < BaseService
    TYPE_RFD = -'RFD' # Duplicate/delayed payment.
    TYPE_TNR = -'TNR' # Product/service no longer available.
    TYPE_QFL = -'QFL' # Customer not satisfied.
    TYPE_TAN = -'TAN' # Event was canceled/changed.
    TYPE_PTH = -'PTH' # Problem not described above.

    def valid_types
      [TYPE_RFD, TYPE_TNR, TYPE_QFL, TYPE_TAN, TYPE_PTH].freeze
    end

    # Creates a refund request.
    #
    # @param payment_id [String] Payment ID of the payment against which you're initiating the refund.
    # @param type [String] A three letter short-code identifying the reason for this case.
    # @param refund_amount [String] This field can be used to specify the refund amount. Default is paid amount.
    # @param body [String] Additional text explaining the refund.
    def create(payment_id, type, refund_amount: nil, body: nil)
      raise InvalidTypeException unless type.in?(valid_types)
      response = post('refunds', payment_id: payment_id, type: type, refund_amount: refund_amount, body: body)
      response[:refund]
    end

    # Returns list of refunds.
    def list
      response = get('refunds')
      response[:refunds]
    end

    # Returns details for a single refund.
    #
    # @param id [String] ID of the refund.
    def details(id)
      response = get("refunds/#{id}")
      response[:refund]
    end
  end
end
