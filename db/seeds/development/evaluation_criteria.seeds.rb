require_relative 'helper'

after 'development:courses' do
  puts 'Seeding evaluation_criteria'

  Course.all.each do |course|
    EvaluationCriterion.create!(name: 'Quality', description:'The default evaluation criteria', course: course)
  end
end
