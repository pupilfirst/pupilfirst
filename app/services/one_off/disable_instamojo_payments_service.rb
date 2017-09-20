module OneOff
  # The service will disable pending payment requests created in the old instamojo account
  class DisableInstamojoPaymentsService
    def initialize(old_account_token)
      @old_account_token = old_account_token
    end

    def execute
      change_api_key_to_old_account
      disable_pending_payments_from_old_account
      switch_api_key_to_new_account
    end

    private

    def disable_pending_payments_from_old_account
      Payment.requested.each do |payment|
        Instamojo::DisablePaymentRequestService.new(payment).disable
      end
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
