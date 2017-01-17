module Users
  class PostmarkWebhookController < ApplicationController
    skip_before_action :verify_authenticity_token
    http_basic_authenticate_with name: ENV['POSTMARK_HOOK_ID'], password: ENV['POSTMARK_HOOK_SECRET']

    def email_bounce
      @user = User.find_by(email: params[:Email])
      return unless @user.present? && params[:Type].in?(target_bounce_types)

      mark_user_unemailable
    end

    private

    def target_bounce_types
      %w(HardBounce BadEmailAddress SpamComplaint)
    end

    def mark_user_unemailable
      @user.update!(email_bounced_at: params[:BouncedAt], email_bounce_type: params[:Type])
    end
  end
end
