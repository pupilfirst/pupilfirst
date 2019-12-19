require 'rails_helper'

describe CourseExports::PrepareService do
  subject { described_class.new(course_export) }

  let(:level_1) { create :level, :one }
  let(:level_2) { create :level, :two, course: level_1.course }
  let(:team_1) { create :team, level: level_2 }
  let(:team_2) { create :team, level: level_1 }
  let(:user_1) { create :user, email: 'a@example.com' }
  let(:user_2) { create :user, email: 'b@example.com' }
  let(:student_1) { create :student, startup: team_1, user: user_1 }
  let!(:student_2) { create :student, startup: team_2, user: user_2 }
  let(:target_group_l1_non_milestone) { create :target_group, level: level_1, sort_index: 0 }
  let(:target_group_l1_milestone) { create :target_group, level: level_1, milestone: true, sort_index: 1 }
  let(:target_group_l2_milesonte) { create :target_group, level: level_2, milestone: true, sort_index: 0 }
  let!(:evaluation_criterion_1) { create :evaluation_criterion, course: course, name: 'Criterion A' }
  let!(:evaluation_criterion_2) { create :evaluation_criterion, course: course, name: 'Criterion B' }
  let!(:target_l1_evaluated) { create :target, target_group: target_group_l1_milestone, evaluation_criteria: [evaluation_criterion_1, evaluation_criterion_2], sort_index: 1 }
  let!(:target_l1_mark_as_complete) { create :target, target_group: target_group_l1_non_milestone }
  let!(:quiz) { create :quiz, target: target_l1_quiz }
  let!(:target_l1_quiz) { create :target, target_group: target_group_l1_milestone, sort_index: 0 }
  let!(:target_l2_evaluated) { create :target, target_group: target_group_l2_milesonte, evaluation_criteria: [evaluation_criterion_1] }
  let(:school) { student_1.school }
  let(:course) { student_1.course }
  let!(:school_admin) { create :school_admin, school: school }
  let(:course_export) { create :course_export, course: course, user: school_admin.user }

  let(:expected_data) do
    [
      {
        title: 'Targets',
        rows: [
          ['ID', "L1T#{target_l1_mark_as_complete.id}", "L1T#{target_l1_quiz.id}", "L1T#{target_l1_evaluated.id}", "L2T#{target_l2_evaluated.id}"],
          ['Level', 1, 1, 1, 2],
          ['Name', target_l1_mark_as_complete.title, target_l1_quiz.title, target_l1_evaluated.title, target_l2_evaluated.title],
          ['Completion Method', 'Mark as Complete', 'Take Quiz', 'Graded', 'Graded'],
          ['Milestone?', 'No', 'Yes', 'Yes', 'Yes'],
          ['Students with submissions'],
          ['Submissions pending review'],
          ['Criterion A (Average Grade)'],
          ['Criterion B (Average Grade)']
        ]
      },
      {
        title: 'Students',
        rows: [
          ['Email Address', 'Name', 'Title', 'Affiliation', 'Tags', 'Criterion A (Average Grade)', 'Criterion B (Average Grade)'],
          [student_1.email, student_1.name, student_1.title, student_1.affiliation, ''],
          [student_2.email, student_2.name, student_2.title, student_2.affiliation, '']
        ]
      },
      {
        title: 'Submissions',
        rows: [
          ['Student Email / Target ID', "L1T#{target_l1_mark_as_complete.id}", "L1T#{target_l1_quiz.id}", "L1T#{target_l1_evaluated.id}", "L2T#{target_l2_evaluated.id}"],
          [student_1.email],
          [student_2.email]
        ]
      }
    ]
  end

  describe '#execute' do
    it 'exports data to an ODS file' do
      expect { subject.execute }.to change { course_export.reload.file.attached? }.from(false).to(true)
      expect(course_export.file.filename.to_s).to end_with('.ods')
    end

    it 'stores data in JSON format' do
      subject.execute

      expect(JSON.parse(course_export.reload.json_data)).to be_an_object_like(expected_data)
    end
  end
end
