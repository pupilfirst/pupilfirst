require_relative 'helper'

after 'development:startups' do
  super_startup = Startup.find_by_name 'Super Startup'

  # Job listed by Super Startup.
  super_startup.startup_jobs.create!(
    title: 'Hacker',
    location: 'Cochin',
    contact_name: 'Some One',
    contact_email: 'someone@mobme.in',
    description: 'This is the job description'
  )
end
