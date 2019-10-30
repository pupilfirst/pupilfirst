after 'development:schools', 'development:users' do
  puts 'Seeding school_admins (production, idempotent)'

  School.all.each do |school|
    admin = school.users.where(email: 'admin@example.com').first_or_create!(name: Faker::Name.name)
    SchoolAdmin.where(user: admin, school: school).first_or_create!
  end
end
