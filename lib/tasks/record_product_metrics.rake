desc 'Record product metrics at the end of every week'
task record_product_metrics: [:environment] do
  ProductMetrics::CollectMetricsService.new.execute
end
