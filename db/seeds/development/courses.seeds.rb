after 'development:schools' do
  puts 'Seeding courses (idempotent)'

  sv = School.find_by(name: 'SV.CO')

  sv.courses.where(name: 'Startup').first_or_create!
  sv.courses.where(name: 'Developer').first_or_create!
  sv.courses.where(name: 'VR').first_or_create!(sponsored: true)
  sv.courses.where(name: 'iOS').first_or_create!(sponsored: true)
end
