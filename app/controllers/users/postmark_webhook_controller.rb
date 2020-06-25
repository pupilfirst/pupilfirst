module Users
  class PostmarkWebhookController < ApplicationController
    skip_before_action :verify_authenticity_token
    http_basic_authenticate_with name: Rails.application.secrets.postmark[:hook_id], password: Rails.application.secrets.postmark[:hook_secret]

    # POST /users/email_bounce
    def email_bounce
      mark_email_bounced if params[:Email].present? && params[:Type].in?(accepted_webhook_types)
      head :ok
    end

    private

    def accepted_webhook_types
      %w[HardBounce SpamComplaint]
    end

    def mark_email_bounced
      BounceReport.where(email: params[:Email]).first_or_create!(bounce_type: params[:Type])
    end
  end
end
