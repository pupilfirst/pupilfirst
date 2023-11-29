module Users
  class PostmarkWebhookController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_request_from_postmark

    # POST /users/email_bounce
    def email_bounce
      if params[:Email].present? && params[:Type].in?(accepted_webhook_types)
        mark_email_bounced
      end
      head :ok
    end

    private

    def authenticate_request_from_postmark
      if authenticate_with_http_basic { |username, password|
           username == ENV["POSTMARK_HOOK_ID"] &&
             password == ENV["POSTMARK_HOOK_SECRET"]
         }
        true
      else
        head :unauthorized
      end
    end

    def accepted_webhook_types
      %w[HardBounce SpamComplaint]
    end

    def mark_email_bounced
      BounceReport.where(email: params[:Email]).first_or_create!(
        bounce_type: params[:Type]
      )
    end
  end
end
