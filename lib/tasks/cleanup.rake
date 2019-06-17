desc 'Cleanup old or stale entries from the database'

task cleanup: [:environment] do
  DatabaseCleanupJob.perform_now
end
