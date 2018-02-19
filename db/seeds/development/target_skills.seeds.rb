require_relative 'helper'

after 'development:targets', 'development:skills' do
  puts 'Seeding target rubric'

  target_group = TargetGroup.find_by(name: 'Put up a Coming Soon Page')
  target = Target.where(target_group: target_group).last
  TargetSkill.create!(
    target: target,
    skill: Skill.first,
    rubric_good: 'Some articulation of why a user will find a solution to this problem valuable.',
    rubric_great: 'A clear articulation of why a user will find a solution to this problem valuable.',
    rubric_wow: 'Clear user needs identified, and a user persona described that has this problem',
    base_karma_points: 20
  )

  TargetSkill.create!(
    target: target,
    skill: Skill.last,
    rubric_good: 'Some analysis of quantitative methods such as market size, or qualitative methods such as interviews and surveys to justify decision.',
    rubric_great: 'Quantitative methods such as market size, competitor traction, or other public research data used to justify decision.',
    rubric_wow: 'Users in the target segment identified & detailed qualitative methods such as interviews and surveys used to justify decisions. Insights from interviews and surveys developed and recorded.',
    base_karma_points: 30
  )
end
