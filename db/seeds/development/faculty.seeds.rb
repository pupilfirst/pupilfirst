require_relative 'helper'

after 'development:levels' do
  puts 'Seeding faculty'

  level_one = Level.find_by(number: 1)
  level_two = Level.find_by(number: 2)

  Faculty.create!(
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

  Faculty.create!(
    name: 'Vishnu Gopal',
    title: 'CTO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/minnie_mouse.jpg').open,
    sort_index: 2,
    level: level_two,
    user: User.create(email: 'minniemouse@example.com')
  )

  Faculty.create!(
    name: 'Gautham',
    title: 'COO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'developer_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/donald_duck.jpg').open,
    sort_index: 3,
    user: User.create(email: 'donaldduck@example.com')
  )

  Faculty.create!(
    name: 'Hari Gopal',
    title: 'Engineering Lead',
    key_skills: 'Looting, pillaging, etc.',
    category: 'visiting_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/jack_sparrow.png').open,
    user: User.create(email: 'goofy@example.com')
  )

  Faculty.create!(
    name: 'iOS Coach',
    title: 'Coaching Expert',
    category: 'developer_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    user: User.create(email: 'ioscoach@example.com')
  )
end
