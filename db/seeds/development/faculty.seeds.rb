require_relative 'helper'

after 'development:levels' do
  puts 'Seeding faculty'

  level_one = Level.find_by(number: 1)
  level_two = Level.find_by(number: 2)

  Faculty.create!(
    name: 'Mickey Mouse',
    email: 'mickeymouse@example.com',
    title: 'CEO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
    sort_index: 1,
    level: level_one
  )

  Faculty.create!(
    name: 'Minne Mouse',
    email: 'minniemouse@example.com',
    title: 'CTO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/minnie_mouse.jpg').open,
    sort_index: 2,
    level: level_two
  )

  Faculty.create!(
    name: 'Donald Duck',
    title: 'CFO',
    key_skills: Faker::Lorem.words(3).join(', '),
    linkedin_url: 'https://linkedin.com',
    category: 'team',
    image: Rails.root.join('spec/support/uploads/faculty/donald_duck.jpg').open,
    sort_index: 3
  )

  Faculty.create!(
    name: 'Jack Sparrow',
    title: 'El Capitan, The Black Pearl',
    key_skills: 'Looting, pillaging, etc.',
    category: 'visiting_coaches',
    image: Rails.root.join('spec/support/uploads/faculty/jack_sparrow.png').open
  )
end
