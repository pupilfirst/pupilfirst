require_relative 'helper'

after 'development:startups' do
  puts 'Seeding payments'

  super_startup = Startup.find_by(legal_registered_name: 'SuperTech Ltd')
  avengers_startup = Startup.find_by(legal_registered_name: 'The Avengers')
  justice_league = Startup.find_by(legal_registered_name: 'Justice League')
  guardians_of_the_galaxy = Startup.find_by(legal_registered_name: 'Guardians of the Galaxy')

  # A live subscription for 'Super Startup' and 'The Avengers'
  fee = Startups::FeeAndCouponDataService.new(super_startup).emi
  super_startup.payments.create!(
    founder: super_startup.team_lead,
    amount: fee,
    paid_at: 1.week.ago,
    payment_type: Payment::TYPE_NORMAL,
    billing_start_at: 1.week.ago,
    billing_end_at: 3.weeks.from_now
  )

  fee = Startups::FeeAndCouponDataService.new(avengers_startup).emi
  avengers_startup.payments.create!(
    founder: avengers_startup.team_lead,
    amount: fee,
    paid_at: 28.days.ago,
    payment_type: Payment::TYPE_NORMAL,
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

  # A live subscription for 'Justice League'
  fee = Startups::FeeAndCouponDataService.new(justice_league).emi
  justice_league.payments.create!(
    founder: justice_league.team_lead,
    amount: fee,
    paid_at: 10.days.ago,
    payment_type: Payment::TYPE_NORMAL,
    billing_start_at: 10.days.ago,
    billing_end_at: 20.days.from_now
  )

  # A live subscription for 'Guardians Of The Galaxy'
  fee = Startups::FeeAndCouponDataService.new(guardians_of_the_galaxy).emi
  guardians_of_the_galaxy.payments.create!(
    founder: guardians_of_the_galaxy.team_lead,
    amount: fee,
    paid_at: 20.days.ago,
    payment_type: Payment::TYPE_NORMAL,
    billing_start_at: 20.days.ago,
    billing_end_at: 10.days.from_now
  )

end
