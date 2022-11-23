require_relative 'helper'

after 'development:courses' do
  puts 'Seeding evaluation_criteria'

  quality_labels = [
    { 'grade' => 1, 'label' => 'Not Accepted' },
    { 'grade' => 2, 'label' => 'Needs Improvement' },
    { 'grade' => 3, 'label' => 'Meets Expectations' },
    { 'grade' => 4, 'label' => 'Exceeds Expectations' }
  ]

  acceptance_labels = [
    { 'grade' => 1, 'label' => 'Rejected' },
    { 'grade' => 2, 'label' => 'Accepted' }
  ]

  Course.all.each do |course|
    EvaluationCriterion.create!(
      name: 'Quality',
      max_grade: 4,
      pass_grade: 2,
      grade_labels: quality_labels,
      course: course
    )

    EvaluationCriterion.create!(
      name: 'Acceptance',
      max_grade: 2,
      pass_grade: 2,
      grade_labels: acceptance_labels,
      course: course
    )
  end
end
