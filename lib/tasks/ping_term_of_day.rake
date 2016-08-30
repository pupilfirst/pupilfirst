desc 'Ping the SaaS channel on Public Slack with a Term of the Day from glossary'
task ping_term_of_day: [:environment] do
  VocalistTermOfTheDayJob.perform_later '#saas'
end
