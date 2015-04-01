require_relative 'helper'

after 'development:users' do
  # Startup with live agreement.
  super_startup = Startup.new(
    name: 'Super Startup',
    agreement_first_signed_at: 18.months.ago,
    agreement_last_signed_at: 6.months.ago,
    agreement_ends_at: 6.months.since,
    incubation_location: Startup::INCUBATION_LOCATION_KOCHI
  )

  # ...whose founder is Some One.
  super_startup.founders << User.find_by(email: 'someone@mobme.in')
  super_startup.save!
end
