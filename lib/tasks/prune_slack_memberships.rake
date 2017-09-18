desc 'Prune Public Slack of founders whose subscription expired 3 days ago'
task prune_slack_memberships: :environment do
  PublicSlack::PruneMembershipService.new.execute
end
