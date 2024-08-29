module Users
  class EditPresenter < ApplicationPresenter
    def page_title
      "User Profile | #{current_school.name}"
    end

    def props
      {
        current_user_id: current_user.id,
        name: current_user.name,
        email: current_user.email,
        preferred_name: current_user.preferred_name || "",
        about: current_user.about || "",
        locale: current_user.locale,
        available_locales: Settings.locale.available,
        has_current_password: current_user.encrypted_password.present?,
        avatar_url:
          if current_user.avatar.attached?
            current_user.avatar_url(variant: :mid)
          else
            nil
          end,
        daily_digest: current_user.preferences["daily_digest"],
        is_school_admin: current_user.school_admin.present?,
        has_valid_delete_account_token: valid_delete_account_token,
        school_name: current_school.name
      }
    end

    def discord_federated_login_url
      "//#{Settings.sso_domain}/oauth/discord?fqdn=#{view.current_host}&session_id=#{encoded_private_session_id}&link_data=true"
    end

    def encoded_private_session_id
      @encoded_private_session_id ||=
        Base64.urlsafe_encode64(view.session.id.private_id)
    end

    private

    def valid_delete_account_token
      return false if current_user.delete_account_sent_at.blank?

      Time.zone.now - current_user.delete_account_sent_at < 30.minutes
    end
  end
end
