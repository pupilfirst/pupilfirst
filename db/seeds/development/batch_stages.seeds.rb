require_relative 'helper'

after 'development:application_stages', 'development:batches' do
  batch_3 = Batch.find_by batch_number: 3

  batch_3.batch_stages.create!(
    application_stage: ApplicationStage.initial_stage,
    starts_at: 5.days.ago,
    ends_at: 25.days.from_now
  )

  batch_3.batch_stages.create!(
    application_stage: ApplicationStage.find_by(number: 2),
    starts_at: 5.days.ago,
    ends_at: 25.days.from_now
  )

  batch_3.batch_stages.create!(
    application_stage: ApplicationStage.find_by(number: 3),
    starts_at: 31.days.from_now,
    ends_at: 36.days.from_now
  )

  batch_3.batch_stages.create!(
    application_stage: ApplicationStage.find_by(number: 4),
    starts_at: 40.days.from_now,
    ends_at: 60.days.from_now
  )

  batch_3.batch_stages.create!(
    application_stage: ApplicationStage.final_stage,
    starts_at: 60.days.from_now
  )
end
