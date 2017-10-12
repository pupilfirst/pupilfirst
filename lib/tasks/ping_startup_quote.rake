desc 'Send a Startup-related quote to #community channel'
task ping_startup_quote: :environment do
  StartupQuotes::PostOnSlackService.new.execute
end
