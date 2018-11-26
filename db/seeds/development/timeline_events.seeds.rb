require_relative 'helper'


after 'development:founders', 'development:targets' do

  puts 'Seeding timeline_events'

  avengers = Startup.find_by(product_name: 'The Avengers')

  def complete_target(target, startup)
    te = TimelineEvent.create!(
      startup: startup,
      target: target,
      founder: startup.team_lead,
      event_on: Time.now,
      description: Faker::Lorem.paragraph,
      status_updated_at: Time.now
    )

    if target.evaluation_criteria.present?
      # Create timeline_event_grades
      grades_for_criteria = te.evaluation_criteria.each_with_object({}) do |ec, grades|
        grades[ec.id] = rand(target.school.pass_grade..target.school.max_grade)
      end

      # Grade the timeline event
      TimelineEvents::GradingService.new(te).grade(startup.faculty.first, grades_for_criteria )
    else
      te.update!(passed_at: Time.now)
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
