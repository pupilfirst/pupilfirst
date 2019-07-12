after 'development:schools' do
  school = School.first

  puts 'Seeding users (idempotent)'

  school.users.where(email: 'admin@example.com').first_or_create!(name: 'Admin User')
end
