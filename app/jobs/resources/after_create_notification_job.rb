module Resources
  # Sends notifications to Slack after a resource is created. This job is triggered as an after_create hook from the
  # Resource model.
  class AfterCreateNotificationJob < ApplicationJob
    queue_as :default

    def perform(resource)
      founders = founders_to_notify(resource)
      PublicSlack::MessageService.new.post(message: message(resource), founders: founders) if founders.present?
    end

    private

    # Message to be send to slack for new resources.
    def message(resource)
      message = '*A new resource'
      message += "has been uploaded to the course Library*:\n\n"
      message += "> *Title:* #{resource.title}\n"
      message += "> *Description:* #{resource.description}\n"
      message + "> *URL:* #{Rails.application.routes.url_helpers.resource_url(id: resource.slug, host: 'https://www.sv.co')}"
    end

    # Returns an array of founders who needs to be notified of the new resource.
    def founders_to_notify(resource)
      Founder.where(startup: Startup.joins(:level).where('levels.course_id = ?', resource.course_id))
    end
  end
end
