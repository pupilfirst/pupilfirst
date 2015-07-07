require_relative 'helper'

after 'development:users' do
  mentor_user = User.find_by email: 'mentor@sv.co'

  Mentor.create!(
    user: mentor_user,
    days_available: Mentor::AVAILABILITY_DAYS_EVERYDAY,
    time_available: Mentor::AVAILABILITY_TIME_ALL_DAY,
    verified_at: Time.now,
    company: 'Startup Village'
  )
end
