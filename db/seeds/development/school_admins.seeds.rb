after 'development:schools', 'users' do
  puts 'Seeding school_admins (idempotent)'

  admin = User.find_by(email: 'admin@example.com')
  sa = User.find_by(email: 'sa@sv.localhost')
  school = School.find_by(name: 'SV.CO')

  [admin, sa].each do |user|
    SchoolAdmin.where(user: user, school: school).first_or_create!
  end
end
