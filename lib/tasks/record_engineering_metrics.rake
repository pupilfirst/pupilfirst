desc 'Record code-coverage and commit stats end of every week'
task record_engineering_metrics: [:environment] do
  EngineeringMetricsRecordJob.perform_later
end
