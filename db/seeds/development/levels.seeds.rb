require_relative 'helper'

puts 'Seeding levels'

Level.create!(number: 0, name: 'Admissions')
Level.create!(number: 1, name: 'Research')
Level.create!(number: 2, name: 'Wireframe', unlock_on: 1.month.from_now)
Level.create!(number: 3, name: 'Prototype', unlock_on: 2.month.from_now)
Level.create!(number: 4, name: 'Launch', unlock_on: 3.month.from_now)