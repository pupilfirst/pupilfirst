module Resources
  # Sends notifications to Slack after a resource is created. This job is triggered as an after_create hook from the
  # Resource model.
  class AfterCreateNotificationJob < ApplicationJob
    queue_as :default

    def perform(resource)
      if resource.level_exclusive?
        PublicSlack::MessageService.new.post message: message(resource), founders: founders_to_notify(resource)
      else
        PublicSlack::MessageService.new.post message: message(resource), channel: '#resources'
      end
    end

    private

    # Message to be send to slack for new resources.
    def message(resource)
      message = '*A new '
      message += resource.level_exclusive? ? "private resource for Level #{resource.level.number} " : 'public resource '
      message += "has been uploaded to the SV.CO Library*:\n\n"
      message += "> *Title:* #{resource.title}\n"
      message += "> *Description:* #{resource.description}\n"
      message + "> *URL:* #{Rails.application.routes.url_helpers.resource_url(id: resource.slug, host: 'https://www.sv.co')}"
    end

    # Returns an array of founders who needs to be notified of the new resource.
    def founders_to_notify(resource)
      if resource.startup.present?
        resource.startup.founders
      elsif resource.level.present?
        Founder.where(startup: Startup.joins(:level).where('levels.number >= ?', resource.level.number))
      else
        Founder.where(startup: Startup.approved)
      end
    end
  end
end
