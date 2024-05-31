module Notifications
  class CreateJob < ApplicationJob
    rescue_from ActiveJob::DeserializationError do |_exception|
      true # Skip processing if either the actor or the resource have been deleted.
    end

    def perform(event, actor, resource)
      unless Notification.events.include?(event)
        raise "Encountered unexpected event #{event}"
      end

      @event = event
      @actor = actor
      @resource = resource

      return if skip?

      users
        .where.not(id: actor.id)
        .each do |recipient|
          I18n.with_locale(recipient.locale) do
            notification =
              Notification.create!(
                actor_id: actor.id,
                notifiable: resource,
                event: Notification.events[event],
                recipient: recipient,
                message: message
              )

            Notifications::DeliverService.new(notification).deliver
          end
        end
    end

    private

    def skip?
      case @event
      when :post_created
        @resource.archived_at?
      when :topic_created
        @resource.archived?
      end
    end

    def users
      case @event
      when :post_created
        @resource.topic.users
      when :topic_created
        @resource.users
      when :submission_comment_created
        User.joins(students: { timeline_event_owners: :timeline_event }).where(
          timeline_events: {
            id: @resource.submission_id
          }
        )
      when :reaction_created
        if @resource.reactionable_type == "TimelineEvent"
          User.joins(
            students: {
              timeline_event_owners: :timeline_event
            }
          ).where(timeline_events: { id: @resource.reactionable_id })
        end
      end
    end

    def message
      case @event
      when :post_created
        I18n.t(
          "jobs.notifications.create.message.post_created",
          user_name: @actor.name,
          community_name: @resource.community.name
        )
      when :topic_created
        I18n.t(
          "jobs.notifications.create.message.topic_created",
          user_name: @actor.name,
          community_name: @resource.community.name
        )
      when :submission_comment_created
        I18n.t(
          "jobs.notifications.create.message.submission_comment_created",
          user_name: @actor.name,
          target_title: @resource.submission.target.title
        )
      when :reaction_created
        if @resource.reactionable_type == "TimelineEvent"
          I18n.t(
            "jobs.notifications.create.message.reaction_created.submission",
            emoji: @resource.reaction_value,
            user_name: @actor.name,
            target_title: @resource.reactionable.target.title
          )
        end
      end
    end
  end
end
