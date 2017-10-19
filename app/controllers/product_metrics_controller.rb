class ProductMetricsController < ApplicationController
  # GET /stats
  def index
    @metrics = ProductMetrics::CollectForIndexService.new.metrics
    @skip_container = true
  end
end
