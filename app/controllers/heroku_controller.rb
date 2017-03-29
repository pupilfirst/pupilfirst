class HerokuController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :deploy_webhook

  def deploy_webhook
    logger.info 'Heroku#deploy_webhook: Received a new deploy hook from Heroku'
    EngineeringMetrics::MetricsStoreService.new.increment :deploys
    head :ok
  end
end
