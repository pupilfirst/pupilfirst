module Notifications
  class ResolvePathService
    include RoutesResolvable

    def initialize(notification)
      @notification = notification
    end

    def resolve
      case @notification.event
        when 'topic_created'
          url_helpers.topic_path(@notification.notifiable_id)
        when 'post_created'
          topic = Post.find(@notification.notifiable_id).topic
          url_helpers.topic_path(topic)
        else
          url_helpers.dashboard_path
      end
    end
  end
end
