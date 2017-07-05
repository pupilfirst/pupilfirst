module StartupFeedbackModule
  class SlackService
    include Loggable
    include ActionView::Helpers::TextHelper

    CommunicationFailure = Class.new(StandardError)

    def initialize(startup_feedback, founder: nil)
      @startup_feedback = startup_feedback
      @founder = founder
    end

    def send
      founders = @startup_feedback.startup.founders
      founders = founders.where(id: @founder.id) if @founder.present?

      log "Posting feedback to public slack for #{pluralize(founders.count, 'founder')}."

      # Post to Slack.
      response = if Rails.env.development?
        OpenStruct.new(errors: {})
      else
        PublicSlack::MessageService.new.post message: @startup_feedback.as_slack_message, founders: founders
      end

      # Fail if no response was received from PublicSlackTalk.
      raise CommunicationFailure if response.blank?

      # Form appropriate flash message with details from response.
      build_response(founders, response)
    end

    private

    def build_response(founders, response)
      success_names = Founder.find(founders.ids - response.errors.keys).map(&:slack_username).join(', ')
      failure_names = Founder.find(founders.ids & response.errors.keys).map(&:fullname).join(', ')
      success_message = success_names.present? ? "Your feedback has been sent as DM to: #{success_names}.\n" : ''
      failure_message = failure_names.present? ? "Failed to ping: #{failure_names}" : ''

      success_message + failure_message
    end
  end
end
