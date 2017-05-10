desc 'Record engineering metrics at the end of every week'
task record_engineering_metrics: [:environment] do
  EngineeringMetrics::MetricsStoreService.new.execute
end
