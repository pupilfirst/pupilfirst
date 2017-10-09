class ProductMetricsController < ApplicationController
  # GET /stats
  def index
    @metrics = ProductMetrics::CollectForIndexService.new.metrics
  end
end
