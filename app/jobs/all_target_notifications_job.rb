class AllTargetNotificationsJob < ActiveJob::Base
  queue_as :default

  def perform(target, notification_type)
    return unless valid_notification_types.include? notification_type

    # initialize a bunch of instance variables for cleaner code
    @target = target
    @notification_type = notification_type
    @startup_url = Rails.application.routes.url_helpers.startup_url(@target.startup)
    @title = @target.title
    @assigner = @target.assigner.name
    @description = ApplicationController.helpers.strip_tags @target.description
    @due_date = @target.due_date&.strftime('%A, %d %b %Y %l:%M %p')
    @resource_url = @target.resource_url

    ping_on_slack(notification_type)
  end

  # ping with appropriate message to the appropriate target based on notification_type received
  def ping_on_slack(notification_type)
    case notification_type
      when 'new_target'
        notify_founders_on_slack message: details_as_slack_message
      when 'revise_target'
        notify_founders_on_slack message: @target.revision_as_slack_message
      when 'mild_reminder'
        notify_founders_on_slack message: mild_slack_reminder
      when 'strong_reminder'
        notify_founders_on_slack message: strong_slack_reminder
      when 'batch_deploy'
        notify_batch_on_slack_channel
    end
  end

  def valid_notification_types
    %w(new_target revise_target mild_reminder strong_reminder batch_deploy)
  end

  def notify_founders_on_slack(message:)
    PublicSlackTalk.post_message message: message, founders: @target.slack_targets
  end

  def notify_batch_on_slack_channel
    channel = @target&.startup&.batch&.slack_channel
    return unless channel.present?

    PublicSlackTalk.post_message message: batch_deploy_message, channel: channel
  end

  def details_as_slack_message
    assignee = @target.assignee.is_a?(Startup) ? "your startup #{@target.assignee.product_name}" : 'you'
    message = I18n.t('slack_notifications.targets.new_target.salutation', assigner: @assigner, assignee: assignee, startup_url: @startup_url, title: @title)
    message += I18n.t('slack_notifications.targets.new_target.description', description: @description)

    message += I18n.t('slack_notifications.targets.new_target.resouce_url', resource_url: @resource_url) if @target.resource_url.present?
    message += I18n.t('slack_notifications.targets.new_target.due_date', due_date: @due_date) if @target.due_date.present?

    message
  end

  def mild_slack_reminder
    assignee = @target.assignee.is_a?(Startup) ? 'Your startup ' + @target.startup.product_name + 'has' : 'You have'
    I18n.t('slack_notifications.targets.mild_reminder', assignee: assignee, startup_url: @startup_url, title: @title, assigner: @assigner)
  end

  def strong_slack_reminder
    assignee = @target.assignee.is_a?(Startup) ? 'your startup ' + @target.startup.product_name : 'you'
    I18n.t('slack_notifications.targets.strong_reminder', startup_url: @startup_url, title: @title, assigner: @assigner, assignee: assignee)
  end

  def batch_deploy_message
    batch_name = @target.startup.batch.name
    message = I18n.t('slack_notifications.targets.batch_deploy.salutation', assigner: @assigner, batch_name: batch_name, title: @title)
    message += I18n.t('slack_notifications.targets.batch_deploy.description', description: @description)

    message += I18n.t('slack_notifications.targets.batch_deploy.resouce_url', resource_url: @resource_url) if @target.resource_url.present?
    message += I18n.t('slack_notifications.targets.batch_deploy.due_date', due_date: @due_date) if @target.due_date.present?

    message
  end
end
