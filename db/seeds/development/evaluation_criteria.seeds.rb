require_relative 'helper'

after 'development:courses' do
  puts 'Seeding evaluation_criteria'

  grade_labels = [{ 'grade' => 1, 'label' => 'Not Accepted' }, { 'grade' => 2, 'label' => 'Needs Improvement' }, { 'grade' => 3, 'label' => 'Meets Expectations' }, { 'grade' => 4, 'label' => 'Exceeds Expectations' }]

  Course.all.each do |course|
    EvaluationCriterion.create!(name: 'Quality', max_grade: 4, pass_grade: 2, grade_labels: grade_labels, course: course)
  end
end
