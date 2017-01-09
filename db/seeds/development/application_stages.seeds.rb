require_relative 'helper'

puts 'Seeding application_stages'

ApplicationStage.create!(number: 1, name: 'Screening')
ApplicationStage.create!(number: 2, name: 'Payment')
ApplicationStage.create!(number: 3, name: 'Coding test')
ApplicationStage.create!(number: 4, name: 'Video test')
ApplicationStage.create!(number: 5, name: 'Interview')
ApplicationStage.create!(number: 6, name: 'Pre-selection')
ApplicationStage.create!(number: 7, name: 'Closed', final_stage: true)
