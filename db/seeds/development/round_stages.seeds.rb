require_relative 'helper'

after 'development:application_stages', 'development:batches' do
  puts 'Seeding round_stages'

  batch = Batch.find_by(batch_number: 3)
  application_rounds = ApplicationRound.where(batch: batch)

  round_in_applications = application_rounds.find_by number: 4 # Round accepting applications.
  round_in_video = application_rounds.find_by number: 3 # Round in video stage.
  round_in_interview = application_rounds.find_by number: 2 # Round in interview stage.
  round_in_pre_selection = application_rounds.find_by number: 1 # Round in pre-selection stage.

  stage_1 = ApplicationStage.initial_stage
  stage_2 = ApplicationStage.find_by(number: 2)
  stage_3 = ApplicationStage.find_by(number: 3)
  stage_4 = ApplicationStage.find_by(number: 4)
  stage_5 = ApplicationStage.find_by(number: 5)
  stage_6 = ApplicationStage.find_by(number: 6)
  stage_7 = ApplicationStage.final_stage

  def create_round_stages(round, details)
    round.round_stages.create!(
      application_stage: details[:stage],
      starts_at: details[:start],
      ends_at: details[:end]
    )
  end

  # Use this guide to set dates.
  #
  # Stage 1 - 30 days + 5 day gap.
  # Stage 2 - Runs parallel to Stage 1
  # Stage 3 - Runs parallel to Stage 1
  # Stage 4 - 25 days + 5 day gap.
  # Stage 5 - 10 days + 5 day gap.
  # Stage 6 - 20 days
  # Stage 7 (closed) - Starts when Stage 6 ends.
  #
  # This adds up to 100 days.

  # Dates for round with applications being accepted.
  [
    { stage: stage_1, start: 2.days.ago, end: 28.days.from_now },
    { stage: stage_2, start: 2.days.ago, end: 28.days.from_now },
    { stage: stage_3, start: 2.days.ago, end: 28.days.from_now },
    { stage: stage_4, start: 33.days.from_now, end: 58.days.from_now },
    { stage: stage_5, start: 63.days.from_now, end: 73.days.from_now },
    { stage: stage_6, start: 78.days.from_now, end: 98.days.from_now },
    { stage: stage_7, start: 98.days.from_now }
  ].each do |stage_details|
    create_round_stages(round_in_applications, stage_details)
  end

  # Dates for round in video task stage.
  [
    { stage: stage_1, start: 37.days.ago, end: 7.days.ago },
    { stage: stage_2, start: 37.days.ago, end: 7.days.ago },
    { stage: stage_3, start: 37.days.ago, end: 7.days.ago },
    { stage: stage_4, start: 2.days.ago, end: 23.days.from_now },
    { stage: stage_5, start: 28.days.from_now, end: 38.days.from_now },
    { stage: stage_6, start: 43.days.from_now, end: 63.days.from_now },
    { stage: stage_7, start: 63.days.from_now }
  ].each do |stage_details|
    create_round_stages(round_in_video, stage_details)
  end

  # Dates for round in interview stage.
  [
    { stage: stage_1, start: 67.days.ago, end: 37.days.ago },
    { stage: stage_2, start: 67.days.ago, end: 37.days.ago },
    { stage: stage_3, start: 67.days.ago, end: 37.days.ago },
    { stage: stage_4, start: 32.days.ago, end: 7.days.ago },
    { stage: stage_5, start: 2.days.ago, end: 8.days.from_now },
    { stage: stage_6, start: 13.days.from_now, end: 33.days.from_now },
    { stage: stage_7, start: 33.days.from_now }
  ].each do |stage_details|
    create_round_stages(round_in_interview, stage_details)
  end

  # Dates for round in pre-selection stage.
  [
    { stage: stage_1, start: 82.days.ago, end: 52.days.ago },
    { stage: stage_2, start: 82.days.ago, end: 52.days.ago },
    { stage: stage_3, start: 82.days.ago, end: 52.days.ago },
    { stage: stage_4, start: 47.days.ago, end: 22.days.from_now },
    { stage: stage_5, start: 17.days.ago, end: 7.days.ago },
    { stage: stage_6, start: 2.days.ago, end: 18.days.from_now },
    { stage: stage_7, start: 18.days.from_now }
  ].each do |stage_details|
    create_round_stages(round_in_pre_selection, stage_details)
  end
end
