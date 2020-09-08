require 'rails_helper'

describe CourseExports::PrepareStudentsExportService do
  include SubmissionsHelper

  subject { described_class.new(course_export) }

  let(:level_1) { create :level, :one }
  let(:level_2) { create :level, :two, course: level_1.course }
  let(:team_1) { create :team, level: level_2, tag_list: ['tag 1', 'tag 2'] }
  let(:team_2) { create :team, level: level_1 }
  let(:user_1) { create :user, email: 'a@example.com', last_sign_in_at: 2.days.ago }
  let(:user_2) { create :user, email: 'b@example.com' }
  let(:student_1) { create :student, startup: team_1, user: user_1 }
  let!(:student_2) { create :student, startup: team_2, user: user_2 }
  let(:target_group_l1_non_milestone) { create :target_group, level: level_1, sort_index: 0 }
  let(:target_group_l1_milestone) { create :target_group, level: level_1, milestone: true, sort_index: 1 }
  let(:target_group_l2_milestone) { create :target_group, level: level_2, milestone: true, sort_index: 0 }
  let!(:evaluation_criterion_1) { create :evaluation_criterion, course: course, name: 'Criterion A' }
  let!(:evaluation_criterion_2) { create :evaluation_criterion, course: course, name: 'Criterion B' }
  let!(:target_l1_evaluated) { create :target, target_group: target_group_l1_milestone, evaluation_criteria: [evaluation_criterion_1, evaluation_criterion_2], sort_index: 1 }
  let!(:target_l1_mark_as_complete) { create :target, target_group: target_group_l1_non_milestone }
  let!(:quiz) { create :quiz, target: target_l1_quiz }
  let!(:target_l1_quiz) { create :target, target_group: target_group_l1_milestone, sort_index: 0 }
  let!(:target_l2_evaluated) { create :target, target_group: target_group_l2_milestone, evaluation_criteria: [evaluation_criterion_1] }
  let(:school) { student_1.school }
  let(:course) { student_1.course }
  let!(:school_admin) { create :school_admin, school: school }
  let(:course_export) { create :course_export, :students, course: course, user: school_admin.user }

  let!(:student_1_reviewed_submission) { complete_target target_l1_evaluated, student_1 }
  let!(:student_2_reviewed_submission) { fail_target target_l1_evaluated, student_2 }

  before do
    # First student has completed everything, but has a pending submission in L2.
    submit_target target_l1_mark_as_complete, student_1
    submission = submit_target target_l1_quiz, student_1
    submission.update!(quiz_score: '2/2')
    submit_target target_l2_evaluated, student_1

    # Second student is still on L1.
    submission = submit_target target_l1_quiz, student_2
    submission.update!(quiz_score: '1/2')
  end

  def submission_grading(submission)
    submission.timeline_event_grades
      .joins(:evaluation_criterion)
      .order('evaluation_criteria.name')
      .pluck(:grade).join(',')
  end

  def report_link_formula(student)
    { 'formula' => "oooc:=HYPERLINK(\"https://test.host/students/#{student.id}/report\"; \"#{student.id}\")" }
  end

  def last_sign_in_at(student)
    student.user.last_sign_in_at&.iso8601 || ''
  end

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
          ['Students with submissions', 1, 2, 2, 1],
          ['Submissions pending review', 0, 0, 0, 1],
          ['Criterion A (2,3) - Average', nil, nil, (evaluation_criterion_1.timeline_event_grades.pluck(:grade).sum / 2.0).round(2).to_s, nil],
          ['Criterion B (2,3) - Average', nil, nil, (evaluation_criterion_2.timeline_event_grades.pluck(:grade).sum / 2.0).round(2).to_s, nil],
        ],
      },
      {
        title: 'Students',
        rows: [
          ['ID', 'Email Address', 'Name', 'Level', 'Title', 'Affiliation', 'Tags', 'Last Sign In At', 'Criterion A (2,3) - Average', 'Criterion B (2,3) - Average'],
          [report_link_formula(student_1), student_1.email, student_1.name, student_1.level.number, student_1.title, student_1.affiliation, 'tag 1, tag 2', last_sign_in_at(student_1), student_1_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_1).grade.to_f.to_s, student_1_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_2).grade.to_f.to_s],
          [report_link_formula(student_2), student_2.email, student_2.name, student_2.level.number, student_2.title, student_2.affiliation, '', last_sign_in_at(student_2), student_2_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_1).grade.to_f.to_s, student_2_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_2).grade.to_f.to_s],
        ],
      },
      {
        title: 'Submissions',
        rows: [
          ['Student Email / Target ID', "L1T#{target_l1_mark_as_complete.id}", "L1T#{target_l1_quiz.id}", "L1T#{target_l1_evaluated.id}", "L2T#{target_l2_evaluated.id}"],
          [student_1.email, '✓', '2/2', { 'value' => submission_grading(student_1_reviewed_submission), 'style' => 'passing-grade' }, { 'value' => 'RP', 'style' => 'pending-grade' }],
          [student_2.email, nil, '1/2', { 'value' => submission_grading(student_2_reviewed_submission), 'style' => 'failing-grade' }],
        ],
      },
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

    context 'when course export data is restricted using options' do
      let(:course_export) { create :course_export, :students, course: course, user: school_admin.user, reviewed_only: true, tag_list: ['tag 1'] }

      before do
        submit_target target_l1_evaluated, student_1
      end

      let(:restricted_data) do
        [
          {
            title: 'Targets',
            rows: [
              ['ID', "L1T#{target_l1_evaluated.id}", "L2T#{target_l2_evaluated.id}"],
              ['Level', 1, 2],
              ['Name', target_l1_evaluated.title, target_l2_evaluated.title],
              ['Completion Method', 'Graded', 'Graded'],
              ['Milestone?', 'Yes', 'Yes'],
              ['Students with submissions', 1, 1],
              ['Submissions pending review', 1, 1],
              ['Criterion A (2,3) - Average', student_1_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_1).grade.to_f.to_s, nil],
              ['Criterion B (2,3) - Average', student_1_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_2).grade.to_f.to_s, nil],
            ],
          },
          {
            title: 'Students',
            rows: [
              ['ID', 'Email Address', 'Name', 'Level', 'Title', 'Affiliation', 'Tags', 'Last Sign In At', 'Criterion A (2,3) - Average', 'Criterion B (2,3) - Average'],
              [report_link_formula(student_1), student_1.email, student_1.name, student_1.level.number, student_1.title, student_1.affiliation, 'tag 1, tag 2', last_sign_in_at(student_1), student_1_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_1).grade.to_f.to_s, student_1_reviewed_submission.timeline_event_grades.find_by(evaluation_criterion: evaluation_criterion_2).grade.to_f.to_s],
            ],
          },
          {
            title: 'Submissions',
            rows: [
              ['Student Email / Target ID', "L1T#{target_l1_evaluated.id}", "L2T#{target_l2_evaluated.id}"],
              [student_1.email, { 'value' => "#{submission_grading(student_1_reviewed_submission)};RP", 'style' => 'pending-grade' }, { 'value' => 'RP', 'style' => 'pending-grade' }],
            ],
          },
        ]
      end

      it 'restricts data in the export' do
        subject.execute

        expect(JSON.parse(course_export.reload.json_data)).to be_an_object_like(restricted_data)
      end
    end
  end
end
