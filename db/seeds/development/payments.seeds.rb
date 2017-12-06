require_relative 'helper'

after 'development:startups' do
  puts 'Seeding payments'

  super_startup = Startup.find_by(legal_registered_name: 'SuperTech Ltd')
  avengers_startup = Startup.find_by(legal_registered_name: 'The Avengers')

  # A live subscription for 'Super Startup' and 'The Avengers'
  fee = Startups::FeePayableService.new(super_startup).undiscounted_fee(period: 3)
  super_startup.payments.create!(
    founder: super_startup.team_lead,
    amount: fee,
    paid_at: 1.week.ago,
    payment_type: Payment::TYPE_ADMISSION,
    billing_start_at: 1.week.ago,
    billing_end_at: 3.weeks.from_now
  )

  fee = Startups::FeePayableService.new(avengers_startup).undiscounted_fee(period: 1)
  avengers_startup.payments.create!(
    founder: avengers_startup.team_lead,
    amount: fee,
    paid_at: 28.days.ago,
    payment_type: Payment::TYPE_ADMISSION,
    billing_start_at: 28.days.ago,
    billing_end_at: 3.days.from_now
  )

  # ...plus a pending payment for 'The Avengers'
  avengers_startup.payments.create!(
    founder: avengers_startup.team_lead,
    amount: fee,
    billing_start_at: 3.days.from_now,
    billing_end_at: 33.days.from_now
  )
end
