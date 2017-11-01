require_relative 'helper'

after 'development:target_groups', 'development:timeline_event_types', 'development:faculty' do
  puts 'Seeding targets'

  video_embed = '<iframe width="560" height="315" src="https://www.youtube.com/embed/58CPRi5kRe8" frameborder="0" allowfullscreen></iframe>'

  def paragraph
    Faker::Lorem.paragraphs.join("\n\n")
  end

  team_update = TimelineEventType.find_by(key: 'team_update')
  faculty_1 = Faculty.first
  faculty_2 = Faculty.second

  # Compulsory Level 0 targets.
  level_0_milestone_group = Level.find_by(number: 0).target_groups.find_by(milestone: true)

  # Screening target.
  screening_target = Target.create!(days_to_complete: 1, title: 'Go through Screening', role: Target::ROLE_TEAM, timeline_event_type: team_update, submittability: Target::SUBMITTABILITY_SUBMITTABLE_ONCE, link_to_complete: '/admissions/screening', key: Target::KEY_ADMISSIONS_SCREENING, target_group: level_0_milestone_group, description: paragraph, assigner: faculty_1, target_action_type: Target::TYPE_TODO)

  # Cofounder addition target.
  cofounder_addition_target = Target.create!(days_to_complete: 1, title: 'Add co-founders', role: Target::ROLE_TEAM, timeline_event_type: team_update, link_to_complete: '/admissions/founders', key: Target::KEY_ADMISSIONS_COFOUNDER_ADDITION, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [screening_target], assigner: faculty_1, target_action_type: Target::TYPE_TODO)

  # Github profile target.
  github_profile_target = Target.create!(days_to_complete: 1, title: 'Submit Github profiles', role: Target::ROLE_TEAM, timeline_event_type: team_update, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [screening_target], assigner: faculty_1, target_action_type: Target::TYPE_TODO)

  # Fee payment target.
  Target.create!(days_to_complete: 1, title: 'Pay Admission Fee', role: Target::ROLE_TEAM, timeline_event_type: team_update, submittability: Target::SUBMITTABILITY_SUBMITTABLE_ONCE, link_to_complete: '/founder/fee', key: Target::KEY_ADMISSIONS_FEE_PAYMENT, target_group: level_0_milestone_group, description: paragraph, prerequisite_targets: [cofounder_addition_target, github_profile_target], assigner: faculty_2, target_action_type: Target::TYPE_TODO)

  # Random targets, session and chores for every level
  (1..4).each do |level_number|
    level = Level.find_by(number: level_number)

    # Two vanilla targets, one chore, and one session per target_group.
    level.target_groups.each do |target_group|
      # Targets.
      2.times do
        target_group.targets.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, target_group: target_group, description: paragraph, assigner: faculty_1, target_action_type: Target::TYPE_TODO)
      end

      # Chore.
      target_group.targets.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, chore: true, description: paragraph, assigner: faculty_2, target_action_type: Target::TYPE_TODO)

      # Session.
      target_group.targets.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, session_at: 1.month.ago, level: level, description: paragraph, assigner: faculty_2, video_embed: video_embed, target_action_type: Target::TYPE_ATTEND)
    end

    # One upcoming session per level.
    Target.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, session_at: (rand(4) + 1).weeks.from_now, level: level, description: paragraph, assigner: faculty_1, video_embed: video_embed, target_action_type: Target::TYPE_ATTEND)

    # One past session per level.
    Target.create!(days_to_complete: [7, 10, 14].sample, title: Faker::Lorem.sentence, role: Target.valid_roles.sample, timeline_event_type: TimelineEventType.all.sample, session_at: (rand(4) + 1).weeks.ago, level: level, description: paragraph, assigner: faculty_2, video_embed: video_embed, target_action_type: Target::TYPE_ATTEND)
  end
end
