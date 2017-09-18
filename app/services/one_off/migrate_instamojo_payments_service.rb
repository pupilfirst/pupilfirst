module OneOff
  # The service will migrate pending payments created using old instamojo account to the new instamojo account
  class MigrateInstamojoPaymentsService
    def initialize(old_account_token)
      @old_account_token = old_account_token
    end

    def execute
      change_api_key_to_old_account
      disable_pending_payments_from_old_account
      switch_api_key_to_new_account
      create_pending_payments_in_new_account
    end

    private

    def disable_pending_payments_from_old_account
      pending_payments.each do |payment|
        Instamojo::DisablePaymentRequestService.new(payment).disable
      end
    end

    def create_pending_payments_in_new_account
      pending_payments.each do |payment|
        Instamojo::RequestPaymentService.new(payment, 1).request
      end
    end

    def pending_payments
      @pending_payments = Payment.requested.where('created_at > ?', DateTime.new(2017, 5, 8))
    end

    def change_api_key_to_old_account
      Rails.application.secrets.instamojo_api_key = @old_account_token[:INSTAMOJO_API_KEY]
      Rails.application.secrets.instamojo_auth_token = @old_account_token[:INSTAMOJO_AUTH_TOKEN]
    end

    def switch_api_key_to_new_account
      Rails.application.secrets.instamojo_api_key = ENV.fetch('INSTAMOJO_API_KEY')
      Rails.application.secrets.instamojo_auth_token = ENV.fetch('INSTAMOJO_AUTH_TOKEN')
    end
  end
end
