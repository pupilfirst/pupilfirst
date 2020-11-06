module Notifications
  class ResolvePathService
    include RoutesResolvable

    def initialize(notification)
      @notification = notification
    end

    def resolve
      case @notification.notifiable_type
        when 'Topic'
          url_helpers.topic_path(@notification.notifiable_id)
        else
          url_helpers.dashboard_path
      end
    end
  end
end
