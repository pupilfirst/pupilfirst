desc "Ping the #memberships channel on the SV.CO's private Slack with stats for previous day"
task ping_membership_stats: [:environment] do
  AdmissionsStatsNotificationJob.perform_now
end
