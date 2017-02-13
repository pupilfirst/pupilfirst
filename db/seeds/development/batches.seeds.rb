require_relative 'helper'

puts 'Seeding batches'

Batch.create!(
  theme: 'FinTech',
  batch_number: 1,
  description: 'The first batch of SV.CO, which is over.',
  start_date: 1.year.ago,
  end_date: 6.months.ago,
  slack_channel: '#fintech'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 2,
  description: 'The second batch of SV.CO which is active.',
  start_date: 3.months.ago,
  end_date: 3.months.from_now,
  slack_channel: '#saas'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 3,
  description: 'The third batch of SV.CO focusing on SaaS Solutions, and whose applications are ongoing.',
  start_date: 1.months.from_now,
  end_date: 7.months.from_now,
  slack_channel: '#saas'
)
