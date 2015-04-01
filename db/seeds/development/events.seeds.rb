require_relative 'helper'

after 'development:categories' do
  event_category = Category.event_category.first

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
