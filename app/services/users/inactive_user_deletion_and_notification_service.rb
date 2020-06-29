module Users
  class InactiveUserDeletionAndNotificationService
    include RoutesResolvable

    def initialize(debug: false)
      @debug = debug
      @debug_value = {}
    end

    def execute
      notify_users_of_deletion
      delete_inactive_users
      @debug_value
    end

    private

    def notify_users_of_deletion
      if @debug
        @debug_value[:users_to_notify] = users_to_notify_deletion.map(&:id)
      else
        users_to_notify_deletion.each do |user|
          UserMailer.notify_account_deletion(user, login_url(user.school), inactivity_duration_for_user_deletion(user) - 1).deliver_later
          user.update!(account_expiry_notification_sent_at: Time.zone.now)
        end
      end
    end

    def delete_inactive_users
      if @debug
        @debug_value[:users_to_delete] = users_to_delete.map(&:id)
      else
        users_to_delete.each do |user|
          Users::DeleteAccountJob.perform_later(user)
        end
      end
    end

    def applicable_schools
      if ENV['DELETE_INACTIVE_USERS_AFTER'].present? && ENV['DELETE_INACTIVE_USERS_AFTER'].to_i != 0
        School.all
      else
        School.where("configuration ? :key", :key => 'deleteInactiveUsersAfter')
      end
    end

    def users_to_notify_deletion
      User.where(school: applicable_schools)
        .where(account_expiry_notification_sent_at: nil).includes(:school).map do |user|

        next if user.last_sign_in_at.blank? || (Time.zone.now - user.last_sign_in_at) < (inactivity_duration_for_user_deletion(user).months - 1.month)

        user
      end - [nil]
    end

    def users_to_delete
      User.where(school: applicable_schools).where('account_expiry_notification_sent_at < ?', 1.month.ago).map do |user|

        next if (Time.zone.now - user.last_sign_in_at) < (inactivity_duration_for_user_deletion(user).months) || user.school_admin.present?

        user
      end - [nil]
    end

    def login_url(school)
      host = school.domains.where(primary: true).first

      url_options = {
        host: host.fqdn,
        protocol: 'https'
      }

      url_helpers.new_user_session_url(url_options)
    end

    def inactivity_duration_for_user_deletion(user)
      user.school.configuration['deleteInactiveUsersAfter'].presence || ENV['DELETE_INACTIVE_USERS_AFTER'].to_i
    end
  end
end
