require_relative 'helper'

puts 'Seeding application_stages'

ApplicationStage.create!(number: 1, name: 'Open')
ApplicationStage.create!(number: 2, name: 'Testing')
ApplicationStage.create!(number: 3, name: 'Interview')
ApplicationStage.create!(number: 4, name: 'Pre-selection')
ApplicationStage.create!(number: 5, name: 'Closed', final_stage: true)
