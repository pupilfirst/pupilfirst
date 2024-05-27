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
        User.joins(students: { timeline_event_owners: :timeline_event })
            .where(timeline_events: { id: @resource.submission_id })
      when :reaction_created
        if @resource.reactionable_type == 'TimelineEvent'
          User.joins(students: { timeline_event_owners: :timeline_event })
              .where(timeline_events: { id: @resource.reactionable_id })
        else
          User.joins(:submission_comments)
              .where(submission_comments: { id: @resource.reactionable_id })
        end
      end
    end

    def message
      case @event
      when :post_created
        I18n.t(
          'jobs.notifications.create.message.post_created',
          user_name: @actor.name,
          community_name: @resource.community.name
        )
      when :topic_created
        I18n.t(
          'jobs.notifications.create.message.topic_created',
          user_name: @actor.name,
          community_name: @resource.community.name
        )
      when :submission_comment_created
        users.count > 1 ?
          I18n.t(
            'jobs.notifications.create.message.comment_created_on_team_submission',
            user_name: @actor.name,
            target_title: @resource.submission.target.title
          ) :
          I18n.t(
            'jobs.notifications.create.message.submission_comment_created',
            user_name: @actor.name,
            target_title: @resource.submission.target.title
          )
      when :reaction_created
        i18n_message_for_reaction
      end
    end

    def i18n_message_for_reaction
      if @resource.reactionable_type == 'TimelineEvent'
        case users.count > 1
        when true
          I18n.t(
            'jobs.notifications.create.message.reaction_created.submission.team_submission',
            user_name: @actor.name,
            emoji: @resource.reaction_value,
            target_title: @resource.reactionable.target.title
          )
        when false
          I18n.t(
            'jobs.notifications.create.message.reaction_created.submission.individual_submission',
            user_name: @actor.name,
            emoji: @resource.reaction_value,
            target_title: @resource.reactionable.target.title
          )
        end
      else
        reactionable_belong_to_submission_owner = @resource.reactionable.user_id.in?(
                                                    @resource.reactionable.submission.students.pluck(:user_id)
                                                  )
        team_submission = users.count > 1
        actor_is_submission_owner = @actor.id.in?(@resource.reactionable.submission.students.pluck(:user_id))


        case [reactionable_belong_to_submission_owner, team_submission, actor_is_submission_owner]
        when [true, false, false]
          I18n.t(
            'jobs.notifications.create.message.reaction_created.for_your_comment_on_your_submission',
            user_name: @actor.name,
            emoji: @resource.reaction_value,
            target_title: @resource.reactionable.submission.target.title
          )
        when [true, true, false]
          I18n.t(
            'jobs.notifications.create.message.reaction_created.for_your_comment_on_your_team_submission',
            user_name: @actor.name,
            emoji: @resource.reaction_value,
            submission_owner: @resource.reactionable.submission.students.first.name,
            target_title: @resource.reactionable.submission.target.title
          )
        when [false, false, true]
          I18n.t(
            'jobs.notifications.create.message.reaction_created.for_your_comment_on_their_submission',
            user_name: @actor.name,
            emoji: @resource.reaction_value,
            target_title: @resource.reactionable.submission.target.title
          )
        when [false, true, true]
          I18n.t(
            'jobs.notifications.create.message.reaction_created.for_your_comment_on_their_team_submission',
            user_name: @actor.name,
            emoji: @resource.reaction_value,
            target_title: @resource.reactionable.submission.target.title
          )
        when [false, false, false]
          I18n.t(
            'jobs.notifications.create.message.reaction_created.for_your_comment_on_others_submission',
            user_name: @actor.name,
            submission_owner: @resource.reactionable.submission.students.first.name,
            emoji: @resource.reaction_value,
            target_title: @resource.reactionable.submission.target.title
          )
        when [false, true, false]
          I18n.t(
            'jobs.notifications.create.message.reaction_created.for_your_comment_on_others_team_submission',
            user_name: @actor.name,
            submission_owner: @resource.reactionable.submission.students.first.name,
            emoji: @resource.reaction_value,
            target_title: @resource.reactionable.submission.target.title
          )
        end
      end
    end
  end
end
