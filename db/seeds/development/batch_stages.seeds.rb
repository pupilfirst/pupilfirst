require_relative 'helper'

after 'development:application_stages', 'development:batches' do
  puts 'Seeding batch_stages'


  batch_applications = Batch.find_by batch_number: 6 # Batch in interview stage.
  batch_interview = Batch.find_by batch_number: 5 # Batch in interview stage.
  batch_pre_selection = Batch.find_by batch_number: 4 # Batch in pre-selection.
  batch_closed = Batch.find_by batch_number: 3 # Batch in closed stage.

  stage_1 = ApplicationStage.initial_stage
  stage_2 = ApplicationStage.find_by(number: 2)
  stage_3 = ApplicationStage.find_by(number: 3)
  stage_4 = ApplicationStage.find_by(number: 4)
  stage_5 = ApplicationStage.final_stage

  # Stages for application batch.

  batch_applications.batch_stages.create!(
    application_stage: stage_1,
    starts_at: 5.days.ago,
    ends_at: 25.days.from_now
  )

  batch_applications.batch_stages.create!(
    application_stage: stage_2,
    starts_at: 5.days.ago,
    ends_at: 25.days.from_now
  )

  batch_applications.batch_stages.create!(
    application_stage: stage_3,
    starts_at: 31.days.from_now,
    ends_at: 36.days.from_now
  )

  batch_applications.batch_stages.create!(
    application_stage: stage_4,
    starts_at: 40.days.from_now,
    ends_at: 60.days.from_now
  )

  batch_applications.batch_stages.create!(
    application_stage: stage_5,
    starts_at: 60.days.from_now
  )

  # Stages for interview batch.

  batch_interview.batch_stages.create!(
    application_stage: stage_1,
    starts_at: 35.days.ago,
    ends_at: 5.days.ago
  )

  batch_interview.batch_stages.create!(
    application_stage: stage_2,
    starts_at: 35.days.ago,
    ends_at: 5.days.ago
  )

  batch_interview.batch_stages.create!(
    application_stage: stage_3,
    starts_at: 2.days.ago,
    ends_at: 7.days.from_now
  )

  batch_interview.batch_stages.create!(
    application_stage: stage_4,
    starts_at: 10.days.from_now,
    ends_at: 30.days.from_now
  )

  batch_interview.batch_stages.create!(
    application_stage: stage_5,
    starts_at: 40.days.from_now
  )

  # Stages for pre_selection batch

  batch_pre_selection.batch_stages.create!(
    application_stage: stage_1,
    starts_at: 55.days.ago,
    ends_at: 25.days.ago
  )

  batch_pre_selection.batch_stages.create!(
    application_stage: stage_2,
    starts_at: 55.days.ago,
    ends_at: 25.days.ago
  )

  batch_pre_selection.batch_stages.create!(
    application_stage: stage_3,
    starts_at: 22.days.ago,
    ends_at: 13.days.ago
  )

  batch_pre_selection.batch_stages.create!(
    application_stage: stage_4,
    starts_at: 5.days.ago,
    ends_at: 15.days.from_now
  )

  batch_pre_selection.batch_stages.create!(
    application_stage: stage_5,
    starts_at: 25.days.from_now
  )

  # Stages for batch in closed stage.

  batch_closed.batch_stages.create!(
    application_stage: stage_1,
    starts_at: 75.days.ago,
    ends_at: 45.days.ago
  )

  batch_closed.batch_stages.create!(
    application_stage: stage_2,
    starts_at: 75.days.ago,
    ends_at: 45.days.ago
  )

  batch_closed.batch_stages.create!(
    application_stage: stage_3,
    starts_at: 42.days.ago,
    ends_at: 33.days.ago
  )

  batch_closed.batch_stages.create!(
    application_stage: stage_4,
    starts_at: 25.days.ago,
    ends_at: 5.days.ago
  )

  batch_closed.batch_stages.create!(
    application_stage: stage_5,
    starts_at: 2.days.ago
  )
end
