require_relative 'helper'

Batch.create!(
  name: 'FinTech',
  batch_number: 1,
  description: 'The first batch of SV.CO focusing on FinTech Solutions',
  start_date: '17-08-2015',
  end_date: '17-02-2016'
)

Batch.create!(
  name: 'SaaS',
  batch_number: 2,
  description: 'The second batch of SV.CO focusing on SaaS Solutions',
  start_date: '28-03-2016',
  end_date: '28-09-2016'
)
