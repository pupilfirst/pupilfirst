# Controller responsible for handling all incoming interaction requests from Slack.
class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :interaction_webhook

  before_action :verify_slack_token

  def interaction_webhook
    # Delegate handling of submission to a job...
    Founders::HandleEnglishQuizSubmissionJob.perform_later(payload) if english_quiz?
    # and immediately respond with a 200.
    head :ok
  end

  private

  def payload
    @payload ||= JSON.parse(params[:payload])
  end

  # Verify the request is indeed from our Slack app.
  def verify_slack_token
    return if payload['token'] == ENV.fetch('SLACK_APP_VERIFICATION_TOKEN')
    head :unauthorized
  end

  def english_quiz?
    payload['callback_id'].match?(/english_quiz_\d+/)
  end
end
