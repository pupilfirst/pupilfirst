require_relative 'helper'


after 'development:founders', 'development:targets' do

  puts 'Seeding timeline_events'

  avengers = Startup.find_by(product_name: 'The Avengers')

  def complete_target(target, startup)
    te = TimelineEvent.create!(
      startup: startup,
      target: target,
      timeline_event_type: target.timeline_event_type,
      founder: startup.team_lead,
      event_on: Time.now,
      description: Faker::Lorem.paragraph,
      status_updated_at: Time.now
    )

    # Create timeline_event_grades

    pass_grade = rand(target.school.pass_grade..target.school.max_grade)

    te.evaluation_criteria.each do |ec|
      te.timeline_event_grades.create!(evaluation_criterion: ec, grade: pass_grade)
    end
  end

  # Complete all Level 1 and Level 2 targets for 'The Avengers'.
  [1, 2].each do |level_number|
    Target.joins(target_group: :level).where(levels: { number: level_number, school_id: avengers.school.id }).each do |target|
      complete_target(target, avengers)
    end
  end

  # Create a pending timeline event in iOS startup.
  ios_founder = Founder.with_email('ios@example.org')
  ios_startup = ios_founder.startup

  TimelineEvent.create!(
    startup: ios_startup,
    founder: ios_founder,
    event_on: Time.now,
    description: 'This is a seeded pending submission for the iOS startup',
    target: ios_startup.school.targets.live.first
  )

end
