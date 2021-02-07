module Notifications
  class PostCreatedJob < ApplicationJob
    queue_as :default

    def perform(actor_id, post_id)
      post = Post.find_by(id: post_id)
      actor = User.find_by(id: actor_id)

      return if post.blank? || actor.blank?

      post.topic.users.where.not(id: actor_id).each do |recipient|
        I18n.with_locale(recipient.locale) do
          notification = Notification.create!(
            actor_id: actor_id,
            notifiable: post,
            event: Notification.events[:post_created],
            recipient: recipient,
            message:
              I18n.t(
                'jobs.notifications.post_created_job.post_created',
                user_name: actor.name,
                community_name: post.community.name,
              )
          )
          Notifications::FireService.new(notification).fire
        end
      end
    end
  end
end
