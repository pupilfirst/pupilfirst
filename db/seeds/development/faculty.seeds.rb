require_relative 'helper'

after 'users' do
  puts 'Seeding faculty'

  Faculty.create!(
    name: 'Sanjay Vijayakumar',
    title: 'CEO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    sort_index: 1,
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

  Faculty.create!(
    name: 'School Admin',
    title: 'School Admin',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    user: User.find_by(email: 'admin@example.com')
  )
end
