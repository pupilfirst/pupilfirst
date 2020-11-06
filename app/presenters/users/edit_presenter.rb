module Users
  class EditPresenter < ApplicationPresenter
    def page_title
      "User Profile | #{current_school.name}"
    end

    def props
      {
        current_user_id: current_user.id,
        name: current_user.name,
        about: current_user.about || '',
        has_current_password: current_user.encrypted_password.present?,
        avatar_url: current_user.avatar.attached? ? current_user.avatar_url(variant: :mid) : nil,
        daily_digest: current_user.preferences['daily_digest'],
        is_school_admin: current_user.school_admin.present?,
        has_valid_delete_account_token: valid_delete_account_token
      }
    end

    private

    def valid_delete_account_token
      return false if current_user.delete_account_sent_at.blank?

      Time.zone.now - current_user.delete_account_sent_at < 30.minutes
    end
  end
end
