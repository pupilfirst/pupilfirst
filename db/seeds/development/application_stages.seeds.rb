require_relative 'helper'

ApplicationStage.create!(number: 1, name: 'Open', days_before_batch: 60)
ApplicationStage.create!(number: 2, name: 'Testing', days_before_batch: 53)
ApplicationStage.create!(number: 3, name: 'Interview', days_before_batch: 21)
ApplicationStage.create!(number: 4, name: 'Pre-selection', days_before_batch: 7)
ApplicationStage.create!(number: 5, name: 'Closed', days_before_batch: 1)
