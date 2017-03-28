class TrelloController < ApplicationController
  def bug_webhook
    unless request.head?
      action_type = params.dig('trello', 'action', 'type')
      label_id = params.dig('trello', 'action', 'data', 'label', 'id')
      valid_type = action_type.in? %w(addLabelToCard removeLabelFromCard)
      valid_label = label_id == Rails.application.secrets.trello['bug_label_id']

      if valid_type && valid_label
        stats_service = EngineeringMetrics::MetricsStoreService.new
        action_type == 'addLabelToCard' ? stats_service.increment(:bugs) : stats_service.decrement(:bugs)
      end
    end

    head :ok
  end
end
