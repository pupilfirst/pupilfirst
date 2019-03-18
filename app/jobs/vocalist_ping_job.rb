# This job sends slack messagess to intended recipients. It accepts { founder: Founder },
# { founders: [array_of_founder_ids]} and { channel: 'channel_id' }
class VocalistPingJob < ApplicationJob
  queue_as :default

  def perform(message, recipients)
    Rails.logger.info "Sending message to recipients : #{recipients.inspect}"
    PublicSlack::MessageService.new.post({ message: message }.merge(parsed_recipients(recipients)))
  end

  private

  def parsed_recipients(recipients)
    if recipients[:founders].present?
      recipients[:founders] = recipients[:founders].map do |founder_id|
        Founder.find(founder_id)
      end
    end

    recipients
  end
end
