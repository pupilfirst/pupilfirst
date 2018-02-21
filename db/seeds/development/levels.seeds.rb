require_relative 'helper'

puts 'Seeding levels'

Level.create!(number: 0, name: 'Admissions')
Level.create!(number: 1, name: 'Research')
Level.create!(number: 2, name: 'Wireframe')
Level.create!(number: 3, name: 'Prototype')
Level.create!(number: 4, name: 'Launch')