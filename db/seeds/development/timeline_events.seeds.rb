require_relative 'helper'


after 'development:founders', 'development:targets' do

  puts 'Seeding timeline_events'

  avengers = Startup.find_by(product_name: 'The Avengers')

  def complete_target(target, startup)
    te = TimelineEvent.create!(
      target: target,
      founders: [startup.founders.first],
      event_on: Time.now,
      description: Faker::Lorem.paragraph,
      latest: true
    )

    if target.evaluation_criteria.present?
      # Create timeline_event_grades
      grades_for_criteria = te.evaluation_criteria.each_with_object({}) do |ec, grades|
        grades[ec.id] = rand(target.course.pass_grade..target.course.max_grade)
      end

      # Grade the timeline event
      TimelineEvents::GradingService.new(te).grade(startup.course.faculty.first, grades_for_criteria )
    else
      te.update!(passed_at: Time.now)
    end
  end

  # Complete all Level 1 and Level 2 targets for 'The Avengers'.
  [1, 2].each do |level_number|
    Target.joins(target_group: :level).where(levels: { number: level_number, course_id: avengers.course.id }).each do |target|
      complete_target(target, avengers)
    end
  end

  # Create a pending timeline event in iOS startup.
  ios_founder = User.with_email('ios@example.org').founders.first
  ios_startup = ios_founder.startup

  TimelineEvent.create!(
    founders: [ios_founder],
    event_on: Time.now,
    description: 'This is a seeded pending submission for the iOS startup',
    target: ios_startup.course.targets.live.first,
    latest: true
  )
end
