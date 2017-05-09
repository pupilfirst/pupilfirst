require_relative 'helper'

after 'development:connect_slots', 'development:startups' do
  puts 'Seeding connect requests'

  mickey = Faculty.find_by(email: 'mickeymouse@example.com')
  super_startup = Startup.find_by(product_name: 'Super Product')

  past_slots = mickey.connect_slots.where('slot_at < ?', Time.now)

  past_slots.each do |past_slot|
    past_slot.create_connect_request!(
      startup: super_startup,
      questions: Faker::Lorem.paragraph,
      status: ConnectRequest::STATUS_CONFIRMED,
      confirmed_at: past_slot.slot_at - 1.day,
      rating_for_faculty: rand(5) + 1,
      rating_for_team: rand(5) + 1
    )
  end
end
