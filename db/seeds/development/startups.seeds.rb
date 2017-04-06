require_relative 'helper'

after 'development:levels', 'development:founders', 'development:timeline_event_types', 'development:batches', 'development:categories' do
  puts 'Seeding startups'

  level_1 = Level.find_by(number: 1)
  level_2 = Level.find_by(number: 2)

  # Startup with live agreement.
  super_startup = Startup.new(
    level: level_1,
    name: 'Super Startup',
    product_name: 'Super Product',
    product_description: 'This really is a superb product! ;)',
    agreement_signed_at: 18.months.ago,
    website: 'https://www.superstartup.in',
    logo: File.open(File.join(Rails.root, "app/assets/images/logo.png")),
    presentation_link: 'https://slideshare.net/superstartupdeck',
    legal_registered_name: 'SuperTech Ltd',
    startup_categories: [StartupCategory.first, StartupCategory.second],
    email: 'help@superstartup.in',
    twitter_link: 'https://twitter.com/superstartup',
    facebook_link: 'https://facebook.com/superstartup',
    product_video_link: 'https://www.youtube.com/ourvideo',
    prototype_link: 'https://www.github.com/superstartup',
    wireframe_link: 'https://drive.google.com/superstartup/wireframe',
    program_started_on: 8.weeks.ago
  )

  # ...whose founder is Some One.
  founder = Founder.find_by(email: 'someone@sv.co')
  super_startup.founders << founder
  super_startup.save!

  # Make founder the startup admin.
  founder.startup_admin = true
  founder.save!

  # Add two more co-founders
  super_startup.founders << Founder.find_by(email: 'thedude@sv.co')
  super_startup.founders << Founder.find_by(email: 'thirdgal@sv.co')

  # a second avengers startup
  avengers_startup = Startup.new(
    name: 'The Avengers',
    level: level_2,
    product_name: 'SuperHeroes',
    product_description: 'Earths Mightiest Heroes joined forces to take on threats that were too big for any one hero to tackle.',
    agreement_signed_at: 2.years.ago,
    website: 'https://www.avengers.co',
    startup_categories: [StartupCategory.second, StartupCategory.last],
    program_started_on: 4.weeks.ago
  )

  # make ironman the team lead
  founder = Founder.find_by(email: 'ironman@avengers.co')
  founder.update!(startup_admin: true)
  avengers_startup.founders << founder

  # Add all the other avengers as founders
  avengers_startup.founders << Founder.find_by(email: 'ultron@avengers.co')
  avengers_startup.founders << Founder.find_by(email: 'wasp@avengers.co')
  avengers_startup.founders << Founder.find_by(email: 'hulk@avengers.co')
  avengers_startup.founders << Founder.find_by(email: 'thor@avengers.co')
  avengers_startup.save!

  # Assign both startups to the first batch
  # TODO: This has to be removed after excising all code that requires a batch
  super_startup.update!(batch: Batch.first)
  avengers_startup.update!(batch: Batch.first)
end
