require_relative 'helper'

after 'development:connect_slots', 'development:startups' do
  puts 'Seeding connect_requests'

  coach = Faculty.first
  team = coach.school.startups.first

  past_slots = coach.connect_slots.where('slot_at < ?', Time.now)

  past_slots.each do |past_slot|
    past_slot.create_connect_request!(
      startup: team,
      questions: Faker::Lorem.paragraph,
      status: ConnectRequest::STATUS_CONFIRMED,
      confirmed_at: past_slot.slot_at - 1.day,
      rating_for_faculty: rand(5) + 1,
      rating_for_team: rand(5) + 1
    )
  end
end
