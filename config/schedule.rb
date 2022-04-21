set :output, "#{path}/log/cron.log"

ENV.each { |k, v| env(k, v) }

every 1.day, at: ENV['SCHEDULE_CLEANUP'] do
  rake 'cleanup'
end

every 1.day, at: ENV['SCHEDULE_DAILY_DIGEST'] do
  rake 'daily_digest'
end

every 1.day, at: ENV['SCHEDULE_NOTIFY_AND_DELETE_INACTIVE_USERS'] do
  rake 'notify_and_delete_inactive_users'
end
