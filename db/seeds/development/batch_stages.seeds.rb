require_relative 'helper'

after 'development:application_stages', 'development:batches' do
  batch_4 = Batch.find_by batch_number: 4

  stage_1 = ApplicationStage.initial_stage
  stage_2 = ApplicationStage.find_by(number: 2)
  stage_3 = ApplicationStage.find_by(number: 3)
  stage_4 = ApplicationStage.find_by(number: 4)
  stage_5 = ApplicationStage.final_stage

  batch_4.batch_stages.create!(
    application_stage: stage_1,
    starts_at: 5.days.ago,
    ends_at: 25.days.from_now
  )

  batch_4.batch_stages.create!(
    application_stage: stage_2,
    starts_at: 5.days.ago,
    ends_at: 25.days.from_now
  )

  batch_4.batch_stages.create!(
    application_stage: stage_3,
    starts_at: 31.days.from_now,
    ends_at: 36.days.from_now
  )

  batch_4.batch_stages.create!(
    application_stage: stage_4,
    starts_at: 40.days.from_now,
    ends_at: 60.days.from_now
  )

  batch_4.batch_stages.create!(
    application_stage: stage_5,
    starts_at: 60.days.from_now
  )

  batch_3 = Batch.find_by batch_number: 3

  batch_3.batch_stages.create!(
    application_stage: stage_1,
    starts_at: 35.days.ago,
    ends_at: 5.days.ago
  )

  batch_3.batch_stages.create!(
    application_stage: stage_2,
    starts_at: 35.days.ago,
    ends_at: 5.days.ago
  )

  batch_3.batch_stages.create!(
    application_stage: stage_3,
    starts_at: 2.days.ago,
    ends_at: 7.days.from_now
  )

  batch_3.batch_stages.create!(
    application_stage: stage_4,
    starts_at: 10.days.from_now,
    ends_at: 30.days.from_now
  )

  batch_3.batch_stages.create!(
    application_stage: stage_5,
    starts_at: 40.days.from_now
  )
end
