require_relative 'helper'

after 'development:batches' do
  puts 'Seeding application_rounds'

  batch = Batch.find_by(batch_number: 3)

  common_details = { target_application_count: 100, batch: batch }

  ApplicationRound.create!(common_details.merge(number: 1, campaign_start_at: 112.days.ago))
  ApplicationRound.create!(common_details.merge(number: 2, campaign_start_at: 97.days.ago))
  ApplicationRound.create!(common_details.merge(number: 3, campaign_start_at: 67.days.ago))
  ApplicationRound.create!(common_details.merge(number: 4, campaign_start_at: 32.days.ago))
end
