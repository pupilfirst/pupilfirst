after 'schools' do
  school = School.first

  puts 'Seeding users (production, idempotent)'

  school.users.where(email: 'admin@example.com').first_or_create!(name: 'Admin User', title: 'Super Admin')
end
