class TrelloController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :bug_webhook

  def bug_webhook
    unless request.head?
      action_type = params.dig('trello', 'action', 'type')
      label_id = params.dig('trello', 'action', 'data', 'label', 'id')
      valid_type = action_type.in? %w(addLabelToCard removeLabelFromCard)
      valid_label = label_id == Rails.application.secrets.trello['bug_label_id']

      if valid_type && valid_label
        logger.info "Trello#bug_webhook: Received #{action_type} activity from Trello"
        metrics_store = EngineeringMetrics::MetricsStoreService.new
        action_type == 'addLabelToCard' ? metrics_store.increment(:bugs) : metrics_store.decrement(:bugs)
      end
    end

    head :ok
  end
end
