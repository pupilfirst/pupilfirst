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
        when 'submission_comment_created'
          target = @notification.notifiable.submission.target
          url_helpers.target_path(target)
        when 'reaction_created'
          if @notification.notifiable.reactionable_type == 'TimelineEvent'
            target = @notification.notifiable.reactionable.target
            url_helpers.target_path(target)
          else
            @target = @notification.notifiable.reactionable.submission.target
            url_helpers.target_path(@target)
          end
        else
          url_helpers.dashboard_path
      end
    end
  end
end
