require_relative 'helper'

puts 'Seeding batches'

Batch.create!(
  theme: 'FinTech',
  batch_number: 1,
  description: 'The first batch of SV.CO focusing on FinTech Solutions',
  start_date: '17-08-2015',
  end_date: '17-02-2016'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 2,
  description: 'The second batch of SV.CO focusing on SaaS Solutions',
  start_date: '28-03-2016',
  end_date: '28-09-2016'
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 3,
  description: 'The third batch of SV.CO focusing on SaaS Solutions, and whose interviews are ongoing',
  start_date: 3.months.from_now,
  end_date: 9.months.from_now
)

Batch.create!(
  theme: 'SaaS',
  batch_number: 4,
  description: 'The fourth batch of SV.CO focusing on SaaS Solutions, and whose applications are ongoing',
  start_date: 6.months.from_now,
  end_date: 12.months.from_now
)
