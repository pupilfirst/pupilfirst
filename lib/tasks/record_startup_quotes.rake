desc 'Check for, and record new startup quotes from startupvitamins.com every day'
task record_startup_quotes: [:environment] do
  StartupQuotes::CollectService.new.execute
end
