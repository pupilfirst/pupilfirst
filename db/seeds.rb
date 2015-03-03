# Create an admin user for the /admin interface. This user is a 'superadmin', who can do everything possible from the
# ActiveAdmin interface.
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', admin_type: 'superadmin')

if Rails.env.development?
  # A user who is founder of Super Startup.
  someone = User.create!(email: 'someone@mobme.in', fullname: 'Some One', password: 'password', password_confirmation: 'password')

  # Startup with live agreement.
  super_startup = Startup.new(
    name: "Super Startup",
    agreement_first_signed_at: 18.months.ago,
    agreement_last_signed_at: 6.months.ago,
    agreement_ends_at: 6.months.since,
    incubation_location: Startup::INCUBATION_LOCATION_KOCHI
  )
  super_startup.founders << someone
  super_startup.save!

  # Job listed by Super Startup.
  super_startup_job = super_startup.jobs.create!(title: 'Hacker', location: 'Cochin', contact_name: 'Some One', contact_number: '9876543210', description: 'This is the job description')

  # Startup partnership with User
  startup_partnership = Partnership.new(startup_id: 1, share_percentage: 20, salary: 12000, cash_contribution: 20000)
  startup_partnership.user_id = someone.id
  startup_partnership.save!

  startup_category = Category.create!(name: "startup_catagory")
  startup_location = Location.create!(title: "Kochi", latitude: Faker::Address.latitude, longitude: Faker::Address.longitude)

  # Startups news posted by user
  startups_news = News.new(title: "example_news_head", picture: Faker::Avatar.image)
  startup_news.user_id = someone.id
  startup_news.save!

  # Events @ startup
  startup_event = Event.new(title: 'Super event',picture: Faker::Avatar.image("my-own-slug"))
  startup_event.location_id = startup_location.id
  startup_event.category_id = startup_category.id
  startup_event.save!

  # startup requests
  startup_request = Request.new(body: "Startup request")
  startup_request.user_id = someone.id
  startup_request.save!

end
