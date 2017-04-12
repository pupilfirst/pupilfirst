require_relative 'helper'

after 'development:target_groups', 'development:timeline_event_types' do
  puts 'Seeding targets'

  def paragraph
    Faker::Lorem.paragraphs.join("\n\n")
  end

  founder_update = TimelineEventType.find_by(key: 'founder_update')
  team_update = TimelineEventType.find_by(key: 'team_update')

  # Compulsory Level 0 targets.
  level_0_milestone_group = Level.find_by(number: 0).target_groups.find_by(milestone: true)

  screening_target = Target.create!(days_to_complete: 1, title: 'Go through Screening', role: Target::ROLE_TEAM, timeline_event_type: team_update, submittability: Target::SUBMITTABILITY_SUBMITTABLE_ONCE, link_to_complete: '/admissions/screening', key: Target::KEY_ADMISSIONS_SCREENING, target_group: level_0_milestone_group, description: paragraph)

  fee_target = Target.create!(days_to_complete: 1, title: 'Pay Admission Fee', role: Target::ROLE_TEAM, timeline_event_type: team_update, submittability: Target::SUBMITTABILITY_SUBMITTABLE_ONCE, link_to_complete: '/admissions/fee', key: Target::KEY_ADMISSIONS_FEE_PAYMENT, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [screening_target])

  cofounder_target = Target.create!(days_to_complete: 1, title: 'Add co-founders', role: Target::ROLE_TEAM, timeline_event_type: team_update, link_to_complete: '/admissions/founders', key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [fee_target])

  coding_target = Target.create!(days_to_complete: 30, title: 'Submit coding task', role: Target::ROLE_TEAM, timeline_event_type: team_update, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [fee_target])

  video_target = Target.create!(days_to_complete: 15, title: 'Submit video task', role: Target::ROLE_TEAM, timeline_event_type: team_update, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [fee_target])

  interview_target = Target.create!(days_to_complete: 30, title: 'Attend Interview', role: Target::ROLE_TEAM, timeline_event_type: team_update, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [coding_target, video_target], key: Target::KEY_ADMISSIONS_ATTEND_INTERVIEW)

  Target.create!(days_to_complete: 15, title: 'Pre-selection', role: Target::ROLE_TEAM, timeline_event_type: team_update, key: Target::KEY_ADMISSIONS_PRE_SELECTION, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [interview_target], link_to_complete: '/admissions/preselection')

  # Random targets, session and chores for every level
  (0..4).each do |level_number|
    level = Level.find_by(number: level_number)

    # 3 normal targets per target_group
    level.target_groups.each do |target_group|
      3.times do
        target_group.targets.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, target_group: target_group, description: paragraph)
      end
    end

    # 3 chores per level
    3.times do
      Target.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, chore: true, level: level, description: paragraph)
    end

    # 3 upcoming sessions per level
    3.times do
      Target.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, session_at: rand(4.weeks).seconds.from_now, level: level, description: paragraph)
    end

    # 3 past sessions per level
    3.times do
      Target.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, session_at: rand(4.weeks).seconds.ago, level: level, description: paragraph)
    end
  end
end
