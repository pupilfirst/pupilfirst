module StartupFeedbackModule
  class SlackService
    include Loggable
    include ActionView::Helpers::TextHelper

    def initialize(startup_feedback, founder: nil)
      @startup_feedback = startup_feedback
      @founder = founder
      @api = PublicSlack::ApiService.new(token: Rails.application.secrets.slack.dig(:app, :bot_oauth_token))
    end

    def send
      founders = @startup_feedback.startup.founders
      founders = founders.where(id: @founder.id) if @founder.present?

      log "Posting feedback to public slack for #{pluralize(founders.count, 'founder')}."

      # Post to Slack.
      errors = Rails.env.development? ? [] : send_message_to_founders(founders)

      # Form appropriate flash message with details from response.
      build_response(founders, errors)
    end

    private

    def slack_message(founder)
      formatted_reference_url = @startup_feedback.reference_url.present? ? "<#{@startup_feedback.reference_url}|recent update>" : "recent update"
      salutation = "Hey! You have some feedback from #{@startup_feedback.faculty.name} on your #{formatted_reference_url}.\n"
      feedback_url = Rails.application.routes.url_helpers.student_url(founder.id, show_feedback: @startup_feedback.id)
      team_id = Rails.application.secrets.slack.dig(:team_ids, :public_slack)
      faculty_user_id = @startup_feedback.faculty.slack_user_id
      coach_url = "slack://user?team=#{team_id}&id=#{faculty_user_id}"
      feedback_text = "<#{feedback_url}|Click here> to view the feedback.\n"
      ping_faculty = "<#{coach_url}|Discuss with Coach> about this feedback."
      salutation + feedback_text + ping_faculty
    end

    def build_response(founders, errors)
      success_names = Founder.find(founders.ids - errors).map(&:slack_username).join(', ')
      failure_names = Founder.find(founders.ids & errors).map(&:fullname).join(', ')
      success_message = success_names.present? ? "Your feedback has been sent as DM to: #{success_names}.\n" : ''
      failure_message = failure_names.present? ? "Failed to ping: #{failure_names}" : ''

      success_message + failure_message
    end

    def send_message_to_founders(founders)
      founders.each_with_object([]) do |founder, errors|
        params = { text: slack_message(founder), channel: founder.slack_user_id, link_names: 1, as_user: 'true', unfurl_links: 'false' }

        begin
          @api.get('chat.postMessage', params: params)
        rescue PublicSlack::OperationFailureException, PublicSlack::ParseFailureException, PublicSlack::TransportFailureException
          errors << founder.id
        end
      end
    end
  end
end
