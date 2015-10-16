require_relative 'helper'

Faculty.create!(
  name: 'Mickey Mouse',
  title: 'CEO',
  key_skills: Faker::Lorem.words(3).join(', '),
  linkedin_url: 'https://linkedin.com',
  category: 'team',
  image: Rails.root.join('spec/support/uploads/faculty/mickey_mouse.jpg').open,
  sort_index: 1
)

Faculty.create!(
  name: 'Minne Mouse',
  title: 'CTO',
  key_skills: Faker::Lorem.words(3).join(', '),
  linkedin_url: 'https://linkedin.com',
  category: 'team',
  image: Rails.root.join('spec/support/uploads/faculty/minnie_mouse.jpg').open,
  sort_index: 2
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
