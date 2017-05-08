class EngineeringMetricsRecordJob < ApplicationJob
  queue_as :default

  def perform
    # store the latest code coverage
    store_service = EngineeringMetrics::MetricsStoreService.new
    store_service.record_code_coverage
  end
end
