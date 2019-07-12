after 'development:schools', 'users' do
  puts 'Seeding school_admins (idempotent)'

  admin = User.find_by(email: 'admin@example.com')
  school = School.first

  SchoolAdmin.where(user: admin, school: school).first_or_create!
end
