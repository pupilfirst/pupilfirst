after 'development:startups', 'development:faculty' do
  puts 'Seeding faculty_startup_enrollments (idempotent)'

  ios_startup = Startup.find_by(name: 'iOS Startup')
  ios_coach = Faculty.find_by(name: 'iOS Coach')
  FacultyStartupEnrollment.where(faculty: ios_coach, startup: ios_startup).first_or_create!(safe_to_create: true)
end
