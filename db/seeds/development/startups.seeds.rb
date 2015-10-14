require_relative 'helper'

after 'development:users', 'development:timeline_event_types' do
  # Startup with live agreement.
  super_startup = Startup.new(
    name: 'Super Startup',
    product_name: 'Super Product',
    product_description: 'This really is a superb product! ;)',
    approval_status: Startup::APPROVAL_STATUS_APPROVED,
    agreement_first_signed_at: 18.months.ago,
    agreement_last_signed_at: 6.months.ago,
    agreement_ends_at: 6.months.since,
    incubation_location: Startup::INCUBATION_LOCATION_KOCHI,
    batch: 1
  )

  # ...whose founder is Some One.
  founder = User.find_by(email: 'someone@mobme.in')
  super_startup.founders << founder
  super_startup.save!

  # Make founder the startup admin.
  founder.startup_admin = true
  founder.save!
end
