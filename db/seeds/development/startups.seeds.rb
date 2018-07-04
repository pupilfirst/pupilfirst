require_relative 'helper'

after 'development:levels', 'development:founders', 'development:timeline_event_types', 'development:categories' do
  puts 'Seeding startups'

  # Level 0 startup.
  level_0 = Level.zero
  john_doe = Founder.find_by(email: 'johndoe@example.com')

  unfinished_swan = Startup.create!(
    product_name: 'Unfinished Swan',
    level: level_0,
    team_lead: john_doe
  )

  john_doe.update!(startup: unfinished_swan)

  startup_school_level_1 = Level.find_by(name: 'Admissions')
  startup_school_level_2 = Level.find_by(name: 'Research')
  developer_school_level_1 = Level.find_by(name: 'Planning')
  vr_school_level_1 = Level.find_by(name: 'New Realities')

  # Startup with live agreement.
  super_startup = Startup.new(
    level: startup_school_level_1,
    product_name: 'Super Product',
    product_description: 'This really is a superb product! ;)',
    agreement_signed_at: 18.months.ago,
    website: 'https://www.superstartup.in',
    logo: File.open(File.join(Rails.root, 'app/assets/images/mailer/logo-mailer.png')),
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

  # ...whose admin is Some One.
  founder = Founder.find_by(email: 'someone@sv.co')
  super_startup.update!(team_lead: founder)
  super_startup.founders << founder

  # Add two more co-founders.
  super_startup.founders << Founder.find_by(email: 'thedude@sv.co')
  super_startup.founders << Founder.find_by(email: 'thirdgal@sv.co')
  super_startup.save!

  # A second 'Avengers' startup.
  avengers_startup = Startup.new(
    name: 'The Avengers',
    level: startup_school_level_2,
    product_name: 'SuperHeroes',
    product_description: 'Earths Mightiest Heroes joined forces to take on threats that were too big for any one hero to tackle.',
    agreement_signed_at: 2.years.ago,
    website: 'https://www.example.org',
    startup_categories: [StartupCategory.second, StartupCategory.last],
    program_started_on: 4.weeks.ago
  )

  # Make ironman the team lead.
  founder = Founder.find_by(email: 'ironman@example.org')
  avengers_startup.update!(team_lead: founder)
  avengers_startup.founders << founder

  # Add all the other avengers as founders.
  avengers_startup.founders << Founder.find_by(email: 'widow@example.org')
  avengers_startup.founders << Founder.find_by(email: 'hulk@example.org')
  avengers_startup.founders << Founder.find_by(email: 'thor@example.org')
  avengers_startup.save!

  # Third startup 'Justice League' for developer school
  justice_league = Startup.new(
    name: 'Justice League',
    level: developer_school_level_1,
    product_name: 'Batmobile',
    product_description: 'The flying car',
    agreement_signed_at: 2.years.ago,
    website: 'https://www.example.org',
    startup_categories: [StartupCategory.first, StartupCategory.last],
    program_started_on: 2.weeks.ago
  )
  # Make Batman the team lead.
  founder = Founder.find_by(email: 'batman@example.org')
  justice_league.update!(team_lead: founder)
  justice_league.founders << founder

  # Add Superman as a founder in 'Justice League'.
  justice_league.founders << Founder.find_by(email: 'superman@example.org')

  # Fourth startup 'Guardians of the Galaxy' for VR school
  guardians_of_the_galaxy = Startup.new(
    name: 'Guardians of the Galaxy',
    level: vr_school_level_1,
    product_name: 'Quad Blasters',
    product_description: 'The Quad Blasters are Star-Lords primary weapons in combat.',
    agreement_signed_at: 1.years.ago,
    website: 'https://www.example.org',
    startup_categories: [StartupCategory.first, StartupCategory.last],
    program_started_on: 1.weeks.ago
  )
  # Make Rocket the team lead.
  founder = Founder.find_by(email: 'rocket@example.org')
  guardians_of_the_galaxy.update!(team_lead: founder)
  guardians_of_the_galaxy.founders << founder

  # Add Groot as a founder in 'Guardians of the Galaxy'.
  guardians_of_the_galaxy.founders << Founder.find_by(email: 'groot@example.org')

end
