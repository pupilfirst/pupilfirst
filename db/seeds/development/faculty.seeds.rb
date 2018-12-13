require_relative 'helper'

after 'development:levels', 'development:schools' do
  puts 'Seeding faculty'

  sv = School.find_by(name: 'SV.CO')
  level_one = Level.find_by(number: 1)
  level_two = Level.find_by(number: 2)

  sv.faculty.create!(
    name: 'Sanjay Vijayakumar',
    title: 'CEO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    sort_index: 1,
    level: level_one,
    user: User.create(email: 'mickeymouse@example.com')
  )

  sv.faculty.create!(
    name: 'Vishnu Gopal',
    title: 'CTO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/minnie_mouse.jpg').open,
    sort_index: 2,
    level: level_two,w
    user: User.create(email: 'minniemouse@example.com')
  )

  sv.faculty.create!(
    name: 'Gautham',
    title: 'COO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'developer_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/donald_duck.jpg').open,
    sort_index: 3,
    user: User.create(email: 'donaldduck@example.com')
  )

  sv.faculty.create!(
    name: 'Hari Gopal',
    title: 'Engineering Lead',
    key_skills: 'Looting, pillaging, etc.',
    category: 'visiting_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/jack_sparrow.png').open,
    user: User.create(email: 'goofy@example.com')
  )

  sv.faculty.create!(
    name: 'iOS Coach',
    title: 'Coaching Expert',
    category: 'developer_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    user: User.create(email: 'ioscoach@example.com')
  )
end
