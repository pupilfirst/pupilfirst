# Create an admin user for the /admin interface. This user is a 'superadmin', who can do everything possible from the
# ActiveAdmin interface.
admin_user = AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', admin_type: 'superadmin')

if Rails.env.development?
  # Let's activate Faker.
  require 'faker'
  I18n.reload!

  # Disable emails.
  ActionMailer::Base.perform_deliveries = false

  # A user who is founder of Super Startup.
  someone = User.create!(email: 'someone@mobme.in', fullname: 'Some One', password: 'password', password_confirmation: 'password')

  # Startup with live agreement.
  super_startup = Startup.new(
    name: 'Super Startup',
    agreement_first_signed_at: 18.months.ago,
    agreement_last_signed_at: 6.months.ago,
    agreement_ends_at: 6.months.since,
    incubation_location: Startup::INCUBATION_LOCATION_KOCHI
  )
  super_startup.founders << someone
  super_startup.save!

  # Job listed by Super Startup.
  super_startup_job = super_startup.startup_jobs.create!(
    title: 'Hacker',
    location: 'Cochin',
    contact_name: 'Some One',
    contact_email: 'someone@mobme.in',
    description: 'This is the job description'
  )

  # Startups news posted by admin
  news = News.create!(
    title: 'Example news title',
    remote_picture_url: Faker::Avatar.image,
    author: admin_user
  )

  event_category = Category.event_category.create!(name: 'Meetup')

  # Pre-approved event
  startup_event = Event.create!(
    title: 'Super event',
    description: 'This is the event description',
    start_at: 1.year.from_now,
    end_at: 2.years.from_now,
    posters_name: Faker::Name.first_name,
    posters_email: 'someone@mobme.in',
    posters_phone_number: '9876543210',
    remote_picture_url: Faker::Avatar.image('my-own-slug'),
    location: 'Startup Village, Kochi',
    category: event_category,
    approved: true
  )
end
