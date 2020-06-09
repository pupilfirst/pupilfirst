require 'rails_helper'

describe CourseExports::PrepareTeamsExportService do
  include SubmissionsHelper

  subject { described_class.new(course_export) }

  let(:level_1) { create :level, :one }
  let(:level_2) { create :level, :two, course: level_1.course }

  let(:team_1) { create :startup, level: level_2, tag_list: ['tag 1', 'tag 2'] }
  let(:team_2) { create :startup, level: level_1 }
  let(:team_3) { create :team, level: level_1 }

  let(:user_t3) { create :user }

  let!(:student_1) { team_1.founders.first }
  let!(:student_2) { team_2.founders.first }
  let!(:student_3) { create :student, startup: team_3, user: user_t3 } # A student who is alone in a team; should also be included.

  let(:target_group_l1_non_milestone) { create :target_group, level: level_1, sort_index: 0 }
  let(:target_group_l1_milestone) { create :target_group, level: level_1, milestone: true, sort_index: 1 }
  let(:target_group_l2_milestone) { create :target_group, level: level_2, milestone: true, sort_index: 0 }

  let!(:evaluation_criterion_1) { create :evaluation_criterion, course: course, name: 'Criterion A' }
  let!(:evaluation_criterion_2) { create :evaluation_criterion, course: course, name: 'Criterion B' }

  let!(:target_l1_evaluated) { create :target, :team, target_group: target_group_l1_milestone, evaluation_criteria: [evaluation_criterion_1, evaluation_criterion_2], sort_index: 1 }
  let!(:target_l1_individual_mark_as_complete) { create :target, :student, target_group: target_group_l1_non_milestone } # Not a team target - should be excluded.
  let!(:target_l1_mark_as_complete) { create :target, :team, target_group: target_group_l1_non_milestone }
  let!(:quiz) { create :quiz, target: target_l1_quiz }
  let!(:target_l1_quiz) { create :target, :team, target_group: target_group_l1_milestone, sort_index: 0 }
  let!(:target_l2_evaluated) { create :target, :team, target_group: target_group_l2_milestone, evaluation_criteria: [evaluation_criterion_1] }

  let(:school) { student_1.school }
  let(:course) { student_1.course }

  let(:coach_1) { create :faculty, school: school }
  let(:coach_2) { create :faculty, school: school }
  let(:coach_3) { create :faculty, school: school }

  let!(:school_admin) { create :school_admin, school: school }
  let(:course_export) { create :course_export, :teams, course: course, user: school_admin.user }

  let!(:team_1_reviewed_submission_1) { complete_target target_l1_evaluated, student_1 }
  let!(:team_1_reviewed_submission_2) { complete_target target_l1_evaluated, student_1 }
  let!(:team_2_reviewed_submission) { fail_target target_l1_evaluated, student_2 }

  before do
    # Assign all three coaches to the course, but only two of those coaches directly to the first student. These two
    # should be the only ones listed in the report.
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_1, startup: team_1
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_2, startup: team_1
    create :faculty_course_enrollment, faculty: coach_3, course: course

    # First student has completed everything, but has a pending submission in L2.
    submit_target target_l1_individual_mark_as_complete, student_1
    submit_target target_l1_mark_as_complete, student_1
    submission = submit_target target_l1_quiz, student_1
    submission.update!(quiz_score: '2/2')
    submit_target target_l2_evaluated, student_1

    # Second student is still on L1.
    submission = submit_target target_l1_quiz, student_2
    submission.update!(quiz_score: '1/2')

    # Third student (alone in team) has only completed one target.
    submit_target target_l1_mark_as_complete, student_3
  end

  def sorted_student_names(team)
    team.founders.joins(:user).pluck('users.name').sort.join(', ')
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

  let(:sorted_coach_names) { [coach_1.name, coach_2.name].sort.join(', ') }

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
          ['Teams with submissions', 2, 2, 2, 1],
          ['Teams pending review', 0, 0, 0, 1],
        ],
      },
      {
        title: 'Teams',
        rows: [
          ['ID', 'Team Name', 'Level', 'Students', 'Coaches', 'Tags'],
          [team_1.id, team_1.name, 2, sorted_student_names(team_1), sorted_coach_names, 'tag 1, tag 2'],
          [team_2.id, team_2.name, 1, sorted_student_names(team_2), '', ''],
          [team_3.id, team_3.name, 1, sorted_student_names(team_3), '', ''],
        ],
      },
      {
        title: 'Submissions',
        rows: [
          ['Team ID', 'Team Name', "L1T#{target_l1_mark_as_complete.id}", "L1T#{target_l1_quiz.id}", "L1T#{target_l1_evaluated.id}", "L2T#{target_l2_evaluated.id}"],
          [team_1.id, team_1.name, '✓', '2/2', { 'value' => "#{submission_grading(team_1_reviewed_submission_1)};#{submission_grading(team_1_reviewed_submission_2)}", 'style' => 'passing-grade' }, { 'value' => 'RP', 'style' => 'pending-grade' }],
          [team_2.id, team_2.name, nil, '1/2', { 'value' => submission_grading(team_2_reviewed_submission), 'style' => 'failing-grade' }, nil],
          [team_3.id, team_3.name, '✓', nil, nil, nil],
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
      let(:course_export) { create :course_export, :teams, course: course, user: school_admin.user, reviewed_only: true, tag_list: ['tag 1'] }

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
              ['Teams with submissions', 1, 1],
              ['Teams pending review', 1, 1],
            ],
          },
          {
            title: 'Teams',
            rows: [
              ['ID', 'Team Name', 'Level', 'Students', 'Coaches', 'Tags'],
              [team_1.id, team_1.name, 2, sorted_student_names(team_1), sorted_coach_names, 'tag 1, tag 2'],
            ],
          },
          {
            title: 'Submissions',
            rows: [
              ['Team ID', 'Team Name', "L1T#{target_l1_evaluated.id}", "L2T#{target_l2_evaluated.id}"],
              [team_1.id, team_1.name, { 'value' => "#{submission_grading(team_1_reviewed_submission_1)};#{submission_grading(team_1_reviewed_submission_2)};RP", 'style' => 'pending-grade' }, { 'value' => 'RP', 'style' => 'pending-grade' }],
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
