require_relative 'helper'

after 'development:founders', 'development:timeline_event_types', 'development:batches', 'development:categories' do
  # Startup with live agreement.
  super_startup = Startup.new(
    name: 'Super Startup',
    product_name: 'Super Product',
    product_description: 'This really is a superb product! ;)',
    approval_status: Startup::APPROVAL_STATUS_APPROVED,
    agreement_signed_at: 18.months.ago,
    batch: Batch.first,
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
    team_size: 3
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
  super_startup.founders << Founder.find_by(email: 'thirdguy@sv.co')
end
