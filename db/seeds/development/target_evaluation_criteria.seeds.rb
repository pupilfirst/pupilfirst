require_relative 'helper'

after 'development:targets', 'development:evaluation_criteria' do
  puts 'Seeding target rubric'

  target_group = TargetGroup.find_by(name: 'Put up a Coming Soon Page')
  target = Target.where(target_group: target_group).last
  TargetEvaluationCriterion.create!(
    target: target,
    evaluation_criterion: target.course.evaluation_criteria.first,
  )
end
