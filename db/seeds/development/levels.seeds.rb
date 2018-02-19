require_relative 'helper'

puts 'Seeding levels'

Level.create!(number: 0, name: 'Admissions')
Level.create!(number: 1, name: 'Select Idea')
Level.create!(number: 2, name: 'Decide What to Build', unlock_on: 1.month.from_now)
Level.create!(number: 3, name: 'Develop an Alpha Product', unlock_on: 2.month.from_now)
Level.create!(number: 4, name: 'Find the First Real Customer', unlock_on: 3.month.from_now)
