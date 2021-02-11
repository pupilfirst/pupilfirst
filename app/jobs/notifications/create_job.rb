module Notifications
  class CreateJob < ApplicationJob
    def perform(event, actor, resource)
      users(event, resource).where.not(id: actor.id).each do |recipient|
        I18n.with_locale(recipient.locale) do
          notification = Notification.create!(
            actor_id: actor.id,
            notifiable: resource,
            event: Notification.events[event],
            recipient: recipient,
            message:
              I18n.t(
                'jobs.notifications.topic_created_job.topic_created',
                user_name: actor.name,
                community_name: topic.community.name,
              )
          )

          Notifications::FireService.new(notification).fire
        end
      end
    end

    def users(event, resource)
      case event
        when :post_created
          resource.topic.users
        when :topic_created
          resource.users
      end
    end

    def message
      case event
        when :post_created
          I18n.t(
            'jobs.notifications.post_created_job.post_created',
            user_name: actor.name,
            community_name: post.community.name,
          )
        when :topic_created
          I18n.t(
            'jobs.notifications.topic_created_job.topic_created',
            user_name: actor.name,
            community_name: topic.community.name,
          )
      end
    end

    def handle_unexpected(event)
      return if Notification.events.include?(event)

      raise "Encountered unexpected event #{event}"
    end
  end
end
