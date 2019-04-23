after 'development:startups', 'development:faculty' do
  puts 'Seeding faculty_startup_enrollments (idempotent)'

  ios_startup = Startup.find_by(name: 'iOS Startup')
  ios_coach = User.find_by(email: 'ioscoach@example.com').faculty.first
  FacultyStartupEnrollment.where(faculty: ios_coach, startup: ios_startup).first_or_create!(safe_to_create: true)
end
