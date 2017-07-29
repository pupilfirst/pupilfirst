desc "Ping the #memberships channel on the SV.CO's private Slack with stats for previous day"
task ping_membership_stats: [:environment] do
  MembershipStatsNotificationJob.perform_now
end
