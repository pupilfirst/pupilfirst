require_relative 'helper'

after 'development:courses' do
  puts 'Seeding evaluation_criteria'

  quality_labels = [
    { 'grade' => 1, 'label' => 'Meets Expectations' },
    { 'grade' => 2, 'label' => 'Exceeds Expectations' }
  ]

  acceptance_labels = [
    { 'grade' => 1, 'label' => 'Accepted' }
  ]

  Course.all.each do |course|
    EvaluationCriterion.create!(
      name: 'Quality',
      max_grade: 2,
      grade_labels: quality_labels,
      course: course
    )

    EvaluationCriterion.create!(
      name: 'Acceptance',
      max_grade: 1,
      grade_labels: acceptance_labels,
      course: course
    )
  end
end
