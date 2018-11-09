require_relative 'helper'

after 'development:schools' do
  puts 'Seeding Evaluation Criteria'

  School.all.each do |school|
    EvaluationCriterion.create!(name: 'Quality', description:'The default evaluation criteria', school: school)
  end
end
