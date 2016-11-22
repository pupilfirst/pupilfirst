require_relative 'helper'

puts 'Seeding batches'

Batch.create!(
  theme: 'FinTech',
  batch_number: 1,
  description: 'The first batch of SV.CO focusing on FinTech Solutions',
  start_date: '17-08-2015',
  end_date: '17-02-2016',
  campaign_start_at: '17-07-2015',
  target_application_count: 100,
  slack_channel: '#fintech'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 2,
  description: 'The second batch of SV.CO focusing on SaaS Solutions',
  start_date: '28-03-2016',
  end_date: '28-09-2016',
  campaign_start_at: '28-01-2016',
  target_application_count: 100,
  slack_channel: '#saas'
)


Batch.create!(
  theme: 'SaaS',
  batch_number: 3,
  description: 'The fifth batch of SV.CO focusing on SaaS Solutions, and whose applications are ongoing',
  start_date: 1.months.from_now,
  end_date: 7.months.from_now,
  campaign_start_at: 6.month.ago,
  target_application_count: 100,
  slack_channel: '#saas'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 4,
  description: 'The third batch of SV.CO focusing on SaaS Solutions, and whose pre-selection is ongoing',
  start_date: 2.months.from_now,
  end_date: 8.months.from_now,
  campaign_start_at: 5.months.ago,
  target_application_count: 100,
  slack_channel: '#saas'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 5,
  description: 'The fourth batch of SV.CO focusing on SaaS Solutions, and whose interviews are ongoing',
  start_date: 3.months.from_now,
  end_date: 9.months.from_now,
  campaign_start_at: 4.months.ago,
  target_application_count: 100,
  slack_channel: '#saas'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 6,
  description: 'The fifth batch of SV.CO focusing on SaaS Solutions, and whose applications are ongoing',
  start_date: 6.months.from_now,
  end_date: 12.months.from_now,
  campaign_start_at: 1.month.ago,
  target_application_count: 100,
  slack_channel: '#saas'
)
