puts 'Seeding Schools'


grade_labels = {
  1 => 'Not Accepted',
  2 => 'Needs Improvement',
  3 => 'Good',
  4 => 'Great',
  5 => 'Wow'
}

School.create!(name: 'Startup', max_grade: 5, pass_grade: 2, grade_labels: grade_labels)
School.create!(name: 'Developer', max_grade: 5, pass_grade: 2, grade_labels: grade_labels)
School.create!(name: 'VR', sponsored: true, max_grade: 5, pass_grade: 2, grade_labels: grade_labels)
School.create!(name: 'iOS', sponsored: true, max_grade: 5, pass_grade: 3, grade_labels: grade_labels)
