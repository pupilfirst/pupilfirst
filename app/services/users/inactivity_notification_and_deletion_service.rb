module Users
  class InactivityNotificationAndDeletionService
    include RoutesResolvable

    def initialize(dry_run: false)
      @dry_run = dry_run
    end

    def execute
      notify_users_of_deletion
      delete_inactive_users
      @results
    end

    private

    def notify_users_of_deletion
      @results = {}
      @results[:users_to_notify] = users_to_notify_deletion

      return if @dry_run

      User.where(id: users_to_notify_deletion).each do |user|
        UserMailer.account_deletion_notification(user, login_url(user.school), deletion_period(user.school) - 1).deliver_later
        user.update!(account_deletion_notification_sent_at: Time.zone.now)
      end
    end

    def delete_inactive_users
      @results[:users_to_delete] = users_to_delete

      return if @dry_run

      User.where(id: users_to_delete).each do |user|
        Users::DeleteAccountJob.perform_later(user)
      end
    end

    def applicable_schools
      if Rails.application.secrets.delete_inactive_users_after.positive?
        School.all
      else
        School.where("configuration ? :key", :key => 'delete_inactive_users_after')
      end
    end

    def users_to_notify_deletion
      @users_to_notify_deletion ||= applicable_schools.map do |school|
        notify_after = deletion_period(school) - 1
        school.users
          .where('last_sign_in_at < ?', notify_after.months.ago)
          .where(account_deletion_notification_sent_at: nil)
          .pluck(:id)
      end.flatten
    end

    def users_to_delete
      @users_to_delete ||= applicable_schools.map do |school|
        delete_after = deletion_period(school)
        school.users
          .where('last_sign_in_at < ?', delete_after.months.ago)
          .where('account_deletion_notification_sent_at < ?', 1.month.ago)
          .pluck(:id)
      end.flatten
    end

    def login_url(school)
      host = school.domains.primary

      url_options = {
        host: host.fqdn,
        protocol: 'https'
      }

      url_helpers.new_user_session_url(url_options)
    end

    def deletion_period(school)
      school.configuration['delete_inactive_users_after'].presence || Rails.application.secrets.delete_inactive_users_after
    end
  end
end
