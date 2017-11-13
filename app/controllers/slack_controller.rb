# Controller responsible for handling all incoming interaction requests from Slack.
class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :interaction_webhook

  before_action :verify_slack_token

  def interaction_webhook
    if english_quiz? && evaluation.present?
      render json: evaluation.to_json
    else
      head :ok
    end
  end

  private

  # Verify the request is indeed from our Slack app.
  def verify_slack_token
    return if payload['token'] == ENV.fetch('SLACK_APP_VERIFICATION_TOKEN')
    head :unauthorized
  end

  def payload
    @payload ||= JSON.parse(params[:payload])
  end

  def english_quiz?
    payload['callback_id'].match?(/english_quiz_\d+/)
  end

  def evaluation
    @evaluation ||= EnglishQuizQuestions::EvaluateSubmissionService.new(payload).evaluate
  end
end
