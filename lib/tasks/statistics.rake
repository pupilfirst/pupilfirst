namespace :statistics do
  desc 'Stores statistics in database.'
  task generate: [:environment] do
    CollectStatisticsJob.perform_later
  end
end