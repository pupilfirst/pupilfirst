require_relative 'helper'

after 'development:courses' do
  puts 'Seeding evaluation_criteria'

  grade_labels = {
    1 => 'Not Accepted',
    2 => 'Needs Improvement',
    3 => 'Meets Expectations',
    4 => 'Exceeds Expectations'
  }

  Course.all.each do |course|
    EvaluationCriterion.create!(name: 'Quality', description: 'The default evaluation criteria', max_grade: 4, pass_grade: 2, grade_labels: grade_labels, course: course)
  end
end
