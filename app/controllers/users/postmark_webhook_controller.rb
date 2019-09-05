module Users
  class PostmarkWebhookController < ApplicationController
    skip_before_action :verify_authenticity_token
    http_basic_authenticate_with name: ENV['POSTMARK_HOOK_ID'], password: ENV['POSTMARK_HOOK_SECRET']

    # POST /users/email_bounce
    def email_bounce
      mark_users_bounced if users.exists? && params[:Type].in?(accepted_webhook_types)
      head :ok
    end

    private

    def users
      @users ||= User.with_email(params[:Email])
    end

    def accepted_webhook_types
      %w[HardBounce SpamComplaint]
    end

    def mark_users_bounced
      users.each do |user|
        user.update!(email_bounced_at: Time.zone.now, email_bounce_type: params[:Type])
      end
    end
  end
end
