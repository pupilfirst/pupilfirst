require "rails_helper"

describe CourseExports::PrepareTeamsExportService do
  include SubmissionsHelper

  subject { described_class.new(course_export) }

  let!(:course) { create :course }
  let!(:cohort_live) { create :cohort, course: course }
  let!(:cohort_2_live) { create :cohort, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }

  let!(:team_1) { create :team, cohort: cohort_live }
  let!(:student_l2_1) do
    create :student,
           cohort: cohort_live,
           tag_list: ["tag 1", "tag 2"],
           team: team_1
  end

  let!(:student_l2_2) do
    create :student,
           cohort: cohort_live,
           tag_list: ["tag 1", "tag 2"],
           team: team_1
  end

  let!(:team_2) { create :team_with_students, cohort: cohort_live }
  let!(:team_3) { create :team, cohort: cohort_live }

  let!(:team_4) { create :team_with_students, cohort: cohort_2_live }
  let!(:student_l2_4) { team_4.students.first }

  let(:user_t3) { create :user }

  let!(:student_1) { team_1.students.first }
  let!(:student_2) { team_2.students.first }
  let!(:student_3) do
    create :student, cohort: cohort_live, team: team_3, user: user_t3
  end # A student who is alone in a team; should also be included.

  let(:target_group_l1_non_milestone) do
    create :target_group, level: level_1, sort_index: 0
  end
  let(:target_group_l1_milestone) do
    create :target_group, level: level_1, sort_index: 1
  end
  let(:target_group_l2_milestone) do
    create :target_group, level: level_2, sort_index: 0
  end

  let!(:evaluation_criterion_1) do
    create :evaluation_criterion, course: course, name: "Criterion A"
  end
  let!(:evaluation_criterion_2) do
    create :evaluation_criterion, course: course, name: "Criterion B"
  end

  let!(:target_l1_evaluated) do
    create :target,
           :team,
           target_group: target_group_l1_milestone,
           evaluation_criteria: [
             evaluation_criterion_1,
             evaluation_criterion_2
           ],
           sort_index: 1,
           milestone: true,
           milestone_number: 1
  end
  let!(:target_l1_individual_mark_as_complete) do
    create :target, :student, target_group: target_group_l1_non_milestone
  end # Not a team target - should be excluded.
  let!(:target_l1_mark_as_complete) do
    create :target, :team, target_group: target_group_l1_non_milestone
  end
  let!(:quiz) { create :quiz, target: target_l1_quiz }
  let!(:target_l1_quiz) do
    create :target,
           :team,
           target_group: target_group_l1_milestone,
           milestone: true,
           milestone_number: 2,
           sort_index: 0
  end
  let!(:target_l2_evaluated) do
    create :target,
           :team,
           target_group: target_group_l2_milestone,
           evaluation_criteria: [evaluation_criterion_1],
           milestone: true,
           milestone_number: 1
  end

  let(:school) { course.school }

  let(:coach_1) { create :faculty, school: school }
  let(:coach_2) { create :faculty, school: school }
  let(:coach_3) { create :faculty, school: school }

  let!(:school_admin) { create :school_admin, school: school }
  let(:course_export) do
    create :course_export,
           :teams,
           course: course,
           cohorts: [cohort_live, cohort_2_live],
           user: school_admin.user
  end

  let!(:team_1_reviewed_submission_1) do
    complete_target target_l1_evaluated, student_1
  end

  let!(:team_1_reviewed_submission_2) do
    complete_target target_l1_evaluated, student_1
  end

  let!(:team_2_reviewed_submission) do
    fail_target target_l1_evaluated, student_2
  end

  let!(:team_4_reviewed_submission) do
    fail_target target_l1_evaluated, student_l2_4
  end

  before do
    # Assign all three coaches to the course, but only two of those coaches directly to the first student. These two
    # should be the only ones listed in the report.
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_1,
           student: student_l2_1
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_2,
           student: student_l2_1

    create :faculty_cohort_enrollment, faculty: coach_3, cohort: cohort_live

    # Student has an archived submission - data should not be present in the export
    create :timeline_event,
           :with_owners,
           latest: false,
           target: target_l1_evaluated,
           owners: [student_1],
           created_at: 3.days.ago,
           archived_at: 1.day.ago

    # First student has completed everything, but has a pending submission in L2.
    submit_target target_l1_individual_mark_as_complete, student_1
    submit_target target_l1_mark_as_complete, student_1
    submission = submit_target target_l1_quiz, student_1
    submission.update!(quiz_score: "2/2")
    submit_target target_l2_evaluated, student_1

    # Second student is still on L1.
    submission = submit_target target_l1_quiz, student_2
    submission.update!(quiz_score: "1/2")

    # Third student (alone in team) has only completed one target.
    submit_target target_l1_mark_as_complete, student_3

    submission = submit_target target_l1_quiz, student_l2_4
    submission.update!(quiz_score: "1/2")
  end

  def sorted_student_names(team)
    team.students.joins(:user).pluck("users.name").sort.join(", ")
  end

  def submission_grading(submission)
    submission
      .timeline_event_grades
      .joins(:evaluation_criterion)
      .order("evaluation_criteria.name")
      .pluck(:grade)
      .join(",")
  end

  def report_link_formula(student)
    {
      "formula" =>
        "oooc:=HYPERLINK(\"https://test.host/students/#{student.id}/report\"; \"#{student.id}\")"
    }
  end

  let(:sorted_coach_names) { [coach_1.name, coach_2.name].sort.join(", ") }

  let(:expected_data) do
    [
      {
        title: "Targets",
        rows: [
          [
            "ID",
            "L1T#{target_l1_mark_as_complete.id}",
            "L1T#{target_l1_quiz.id}",
            "L1T#{target_l1_evaluated.id}",
            "L2T#{target_l2_evaluated.id}"
          ],
          ["Level", 1, 1, 1, 2],
          [
            "Name",
            target_l1_mark_as_complete.title,
            target_l1_quiz.title,
            target_l1_evaluated.title,
            target_l2_evaluated.title
          ],
          [
            "Completion Method",
            "Mark as Complete",
            "Take Quiz",
            "Graded",
            "Graded"
          ],
          %w[Milestone? No Yes Yes Yes],
          ["Teams with submissions", 2, 3, 3, 1],
          ["Teams pending review", 0, 0, 0, 1]
        ]
      },
      {
        title: "Teams",
        rows: [
          ["ID", "Team Name", "Cohort", "Students"],
          [
            team_1.id,
            team_1.name,
            team_1.cohort.name,
            sorted_student_names(team_1)
          ],
          [
            team_2.id,
            team_2.name,
            team_2.cohort.name,
            sorted_student_names(team_2)
          ],
          [
            team_3.id,
            team_3.name,
            team_3.cohort.name,
            sorted_student_names(team_3)
          ],
          [
            team_4.id,
            team_4.name,
            team_4.cohort.name,
            sorted_student_names(team_4)
          ]
        ]
      },
      {
        title: "Submissions",
        rows: [
          [
            "Team ID",
            "Team Name",
            "L1T#{target_l1_mark_as_complete.id}",
            "L1T#{target_l1_quiz.id}",
            "L1T#{target_l1_evaluated.id}",
            "L2T#{target_l2_evaluated.id}"
          ],
          [
            team_1.id,
            team_1.name,
            "✓",
            "2/2",
            {
              "value" =>
                "#{submission_grading(team_1_reviewed_submission_1)};#{submission_grading(team_1_reviewed_submission_2)}",
              "style" => "passing-grade"
            },
            { "value" => "RP", "style" => "pending-grade" }
          ],
          [
            team_2.id,
            team_2.name,
            nil,
            "1/2",
            {
              "value" => submission_grading(team_2_reviewed_submission),
              "style" => "failing-grade"
            },
            nil
          ],
          [team_3.id, team_3.name, "✓", nil, nil, nil],
          [
            team_4.id,
            team_4.name,
            nil,
            "1/2",
            {
              "value" => submission_grading(team_4_reviewed_submission),
              "style" => "failing-grade"
            },
            nil
          ]
        ]
      }
    ]
  end

  describe "#execute" do
    it "exports data to an ODS file" do
      expect { subject.execute }.to change {
        course_export.reload.file.attached?
      }.from(false).to(true)
      expect(course_export.file.filename.to_s).to end_with(".ods")
    end

    it "stores data in JSON format" do
      subject.execute

      expect(JSON.parse(course_export.reload.json_data)).to be_an_object_like(
        expected_data
      )
    end

    context "when course export data is restricted using options" do
      let(:course_export) do
        create :course_export,
               :teams,
               course: course,
               user: school_admin.user,
               reviewed_only: true,
               tag_list: ["tag 1"]
      end

      before { submit_target target_l1_evaluated, student_1 }

      let(:restricted_data) do
        [
          {
            title: "Targets",
            rows: [
              [
                "ID",
                "L1T#{target_l1_evaluated.id}",
                "L2T#{target_l2_evaluated.id}"
              ],
              ["Level", 1, 2],
              ["Name", target_l1_evaluated.title, target_l2_evaluated.title],
              ["Completion Method", "Graded", "Graded"],
              %w[Milestone? Yes Yes],
              ["Teams with submissions", 1, 1],
              ["Teams pending review", 1, 1]
            ]
          },
          {
            title: "Teams",
            rows: [
              ["ID", "Team Name", "Cohort", "Students"],
              [
                team_1.id,
                team_1.name,
                team_1.cohort.name,
                sorted_student_names(team_1)
              ]
            ]
          },
          {
            title: "Submissions",
            rows: [
              [
                "Team ID",
                "Team Name",
                "L1T#{target_l1_evaluated.id}",
                "L2T#{target_l2_evaluated.id}"
              ],
              [
                team_1.id,
                team_1.name,
                {
                  "value" =>
                    "#{submission_grading(team_1_reviewed_submission_1)};#{submission_grading(team_1_reviewed_submission_2)};RP",
                  "style" => "pending-grade"
                },
                { "value" => "RP", "style" => "pending-grade" }
              ]
            ]
          }
        ]
      end

      it "restricts data in the export" do
        subject.execute

        expect(JSON.parse(course_export.reload.json_data)).to be_an_object_like(
          restricted_data
        )
      end
    end
  end
end
