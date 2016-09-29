desc 'Ping the Admissions channel on the Team Slack with Admission Stats Daily'
task ping_admission_stats: [:environment] do
  AdmissionStatsNotificationJob.perform_later
end
