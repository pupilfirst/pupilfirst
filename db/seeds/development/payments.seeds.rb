require_relative 'helper'

after 'development:startups' do
  puts 'Seeding payments'

  # A live subscription for 'Super Startup'
  super_startup = Startup.find_by(legal_registered_name: 'SuperTech Ltd')
  active_payment = Payment.create!(
    startup: super_startup,
    founder: super_startup.admin,
    amount: super_startup.fee,
    paid_at: 1.week.ago,
    billing_start_at: 1.week.ago,
    billing_end_at: 3.weeks.from_now
  )
  super_startup.payments << active_payment

  # A pending payment for 'The Avengers'
  avengers_startup = Startup.find_by(legal_registered_name: 'The Avengers')
  pending_payment = Payment.create!(
    startup: avengers_startup,
    founder: avengers_startup.admin,
    amount: avengers_startup.fee,
    billing_start_at: 1.day.ago,
    billing_end_at: 29.days.from_now
  )
  avengers_startup.payments << pending_payment
end
