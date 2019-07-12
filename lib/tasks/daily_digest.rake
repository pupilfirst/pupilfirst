desc 'Send daily digest mails'
task daily_digest: :environment do
  DailyDigestService.new.execute
end
