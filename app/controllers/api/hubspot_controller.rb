module Api
  class HubspotController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def create
      verify_hubspot_signature!
      TransactionalService.new(
        WebhookHandlers::HubspotService.new
      ).execute(request_params)
      head :ok
    rescue => e
      logger.error e.message
      logger.error e.backtrace.join("\n")

      render json: { error: { message: e.message, backtrace: e.backtrace } }, status: :internal_server_error
    end

    private

    def verify_hubspot_signature!
      raise ActionController::NotAuthorized unless
        valid_signature_version? && valid_signature?
    end

    def valid_signature_version?
      request.headers['HTTP_X_HUBSPOT_SIGNATURE_VERSION'] == 'v1'
    end

    def valid_signature?
      Rack::Utils.secure_compare(request.headers['HTTP_X_HUBSPOT_SIGNATURE'], request_signature)
    end

    def request_signature
      ::Digest::SHA256.hexdigest(
        [
          Rails.application.secrets.hubspot[:client_secret],
          request_params.to_json.to_s
        ].join
      )
    end

    def request_params
      params.require(:_json).map(&:permit!).map(&:to_h)
    end
  end
end