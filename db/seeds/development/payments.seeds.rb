require_relative 'helper'

after 'development:startups' do
  puts 'Seeding payments'

  super_startup = Startup.find_by(legal_registered_name: 'SuperTech Ltd')
  avengers_startup = Startup.find_by(legal_registered_name: 'The Avengers')
  justiceLeague_startup = Startup.find_by(legal_registered_name: 'Justice League')
  guardiansOfTheGalaxy_startup = Startup.find_by(legal_registered_name: 'Guardians of the Galaxy')



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
  fee = Startups::FeeAndCouponDataService.new(justiceLeague_startup).emi
  justiceLeague_startup.payments.create!(
    founder: justiceLeague_startup.team_lead,
    amount: fee,
    paid_at: 10.days.ago,
    payment_type: Payment::TYPE_NORMAL,
    billing_start_at: 10.days.ago,
    billing_end_at: 20.days.from_now
  )

  # A live subscription for 'Guardians Of The Galaxy'
  fee = Startups::FeeAndCouponDataService.new(guardiansOfTheGalaxy_startup).emi
  guardiansOfTheGalaxy_startup.payments.create!(
    founder: guardiansOfTheGalaxy_startup.team_lead,
    amount: fee,
    paid_at: 20.days.ago,
    payment_type: Payment::TYPE_NORMAL,
    billing_start_at: 20.days.ago,
    billing_end_at: 10.days.from_now
  )

end
