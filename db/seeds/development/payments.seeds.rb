require_relative 'helper'

after 'development:startups' do
  puts 'Seeding payments'

  super_startup = Startup.find_by(legal_registered_name: 'SuperTech Ltd')
  avengers_startup = Startup.find_by(legal_registered_name: 'The Avengers')

  # A live subscription for 'Super Startup' and 'The Avengers'
  super_startup.payments.create!(
    founder: super_startup.team_lead,
    amount: super_startup.fee(3),
    paid_at: 1.week.ago,
    billing_start_at: 1.week.ago,
    billing_end_at: 3.weeks.from_now
  )

  avengers_startup.payments.create!(
    founder: avengers_startup.team_lead,
    amount: avengers_startup.fee(1),
    paid_at: 28.days.ago,
    billing_start_at: 28.days.ago,
    billing_end_at: 3.days.from_now
  )

  # ...plus a pending payment for 'The Avengers'
  avengers_startup.payments.create!(
    founder: avengers_startup.team_lead,
    amount: avengers_startup.fee(1),
    billing_start_at: 3.days.from_now,
    billing_end_at: 33.days.from_now
  )
end
