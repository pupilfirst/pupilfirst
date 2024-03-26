require "rails_helper"

describe Courses::DeleteService do
  include SubmissionsHelper

  subject { described_class.new(course_1) }

  let(:common_coach) { create :faculty }
  let(:coach_c1) { create :faculty }
  let(:coach_c2) { create :faculty }

  # Course 1 - will be deleted.
  let(:course_1) do
    create :course, :with_default_cohort, name: "Course to delete"
  end
  let(:cohort_1) { create :cohort, course: course_1 }
  let(:level_c1) { create :level, :one, course: course_1, name: "C1L1" }
  let!(:team_c1) { create :team_with_students, cohort: cohort_1 }
  let!(:student_c1) { create :student, cohort: cohort_1 }
  let!(:applicant_c1) { create :applicant, course: course_1 }
  let(:certificate_c1) { create :certificate, course: course_1 }
  let!(:issued_certificate_c1) do
    create :issued_certificate, certificate: certificate_c1
  end
  let!(:community_course_connection_c1) do
    create :community_course_connection, course: course_1
  end
  let!(:course_author_c1) { create :course_author, course: course_1 }
  let!(:course_export_c1) { create :course_export, :teams, course: course_1 }
  let!(:faculty_cohort_enrollment_c1) do
    create :faculty_cohort_enrollment, cohort: cohort_1, faculty: common_coach
  end
  let!(:faculty_student_enrollment_c1) do
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_c1,
           student: student_c1
  end
  let!(:coach_note_c1) do
    create :coach_note, author: coach_c1.user, student: student_c1
  end
  let(:evaluation_criterion_c1) do
    create :evaluation_criterion, course: course_1
  end
  let!(:target_group_c1) do
    create :target_group, level: level_c1, sort_index: 0
  end
  let!(:target_reviewed_c1) do
    create :target,
           :with_content,
           :with_shared_assignment,
           target_group: target_group_c1,
           given_evaluation_criteria: [evaluation_criterion_c1]
  end
  let!(:topic_c1) do
    create :topic,
           :with_first_post,
           target: target_reviewed_c1,
           community: community_course_connection_c1.community
  end
  let!(:resource_version_c1) do
    create :resource_version, versionable: target_reviewed_c1
  end
  let!(:target_with_quiz_c1) do
    create :target, :with_content, target_group: target_group_c1
  end
  let!(:assignment_target_with_quiz_c1) do
    create :assignment,
           target: target_with_quiz_c1,
           prerequisite_assignments: [target_reviewed_c1.assignments.first]
  end
  let!(:quiz_c1) do
    create(
      :quiz,
      :with_question_and_answers,
      assignment: assignment_target_with_quiz_c1
    )
  end
  let!(:submission_c1) do
    complete_target(target_reviewed_c1, student_c1, evaluator: common_coach)
  end
  let!(:submission_file_c1) do
    create :timeline_event_file, timeline_event: submission_c1
  end
  let!(:feedback_c1) do
    create :startup_feedback,
           faculty: common_coach,
           timeline_event: submission_c1
  end

  #create moderation reports on submission
  let!(:moderation_report_c1) do
    create :moderation_report, user: coach_c1.user, reportable: submission_c1
  end
  #create submission comments
  let!(:submission_comment_c1) do
    create :submission_comment,
           user: course_author_c1.user,
           submission: submission_c1
  end

  #create reactions on submissions
  let!(:reaction_c1) do
    create :reaction, user: student_c1.user, reactionable: submission_c1
  end

  # Course 2 - should be left untouched.
  let(:course_2) do
    create :course, :with_default_cohort, name: "Course to preserve"
  end
  let(:cohort_2) { create :cohort, course: course_2 }
  let(:level_c2) { create :level, :one, course: course_2, name: "C2L1" }
  let!(:team_c2) { create :team_with_students, cohort: cohort_2 }
  let!(:student_c2) { create :student, cohort: cohort_2 }
  let!(:applicant_c2) { create :applicant, course: course_2 }
  let(:certificate_c2) { create :certificate, course: course_2 }
  let!(:issued_certificate_c2) do
    create :issued_certificate, certificate: certificate_c2
  end
  let!(:community_course_connection_c2) do
    create :community_course_connection, course: course_2
  end
  let!(:course_author_c2) { create :course_author, course: course_2 }
  let!(:course_export_c2) { create :course_export, :teams, course: course_2 }
  let!(:faculty_cohort_enrollment_c2) do
    create :faculty_cohort_enrollment, cohort: cohort_2, faculty: common_coach
  end
  let!(:faculty_student_enrollment_c2) do
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_c2,
           student: student_c2
  end
  let!(:coach_note_c2) do
    create :coach_note, author: coach_c2.user, student: student_c2
  end
  let(:evaluation_criterion_c2) do
    create :evaluation_criterion, course: course_2
  end
  let!(:target_group_c2) do
    create :target_group, level: level_c2, sort_index: 0
  end
  let!(:target_reviewed_c2) do
    create :target,
           :with_content,
           :with_shared_assignment,
           target_group: target_group_c2,
           given_evaluation_criteria: [evaluation_criterion_c2]
  end
  let!(:topic_c2) do
    create :topic,
           :with_first_post,
           target: target_reviewed_c2,
           community: community_course_connection_c2.community
  end
  let!(:resource_version_c2) do
    create :resource_version, versionable: target_reviewed_c2
  end
  let!(:target_with_quiz_c2) do
    create :target, :with_content, target_group: target_group_c2
  end
  let!(:assignment_target_with_quiz_c2) do
    create :assignment,
           target: target_with_quiz_c2,
           prerequisite_assignments: [target_reviewed_c2.assignments.first]
  end
  let!(:quiz_c2) do
    create(
      :quiz,
      :with_question_and_answers,
      assignment: assignment_target_with_quiz_c2
    )
  end
  let!(:submission_c2) do
    complete_target(target_reviewed_c2, student_c2, evaluator: common_coach)
  end
  let!(:submission_file_c2) do
    create :timeline_event_file, timeline_event: submission_c2
  end
  let!(:feedback_c2) do
    create :startup_feedback,
           faculty: common_coach,
           timeline_event: submission_c2
  end
  #create moderation reports on submission
  let!(:moderation_report_c2) do
    create :moderation_report, user: coach_c2.user, reportable: submission_c2
  end
  #create submission comments
  let!(:submission_comment_c2) do
    create :submission_comment,
           user: course_author_c2.user,
           submission: submission_c2
  end

  #create reactions on submissions
  let!(:reaction_c2) do
    create :reaction, user: student_c2.user, reactionable: submission_c2
  end

  before do
    # Tag the course exports.
    course_export_c1.tag_list.add("export tag c1")
    course_export_c1.save!
    course_export_c2.tag_list.add("export tag c2")
    course_export_c2.save!

    # Tag the Students.
    student_c1.tag_list.add("student tag c1")
    student_c1.save!
    student_c2.tag_list.add("student tag c2")
    student_c2.save!
  end

  let(:expectations) do
    [
      [Proc.new { Faculty.count }, 3, 3],
      [Proc.new { Course.count }, 2, 1],
      [Proc.new { Cohort.count }, 4, 2],
      [Proc.new { Level.count }, 2, 1],
      [Proc.new { Team.count }, 2, 1],
      [Proc.new { Student.count }, 6, 3],
      [Proc.new { Applicant.count }, 2, 1],
      [Proc.new { Certificate.count }, 2, 1],
      [Proc.new { IssuedCertificate.count }, 2, 1],
      [Proc.new { CommunityCourseConnection.count }, 2, 1],
      [Proc.new { CourseAuthor.count }, 2, 1],
      [Proc.new { CourseExport.count }, 2, 1],
      [Proc.new { FacultyCohortEnrollment.count }, 4, 2],
      [Proc.new { FacultyStudentEnrollment.count }, 2, 1],
      [Proc.new { CoachNote.count }, 2, 1],
      [Proc.new { EvaluationCriterion.count }, 2, 1],
      [Proc.new { TimelineEventGrade.count }, 2, 1],
      [Proc.new { AssignmentsEvaluationCriterion.count }, 2, 1],
      [Proc.new { TargetGroup.count }, 2, 1],
      [Proc.new { Target.count }, 4, 2],
      [Proc.new { Assignment.count }, 4, 2],
      [Proc.new { AssignmentsPrerequisiteAssignment.count }, 2, 1],
      [Proc.new { TargetVersion.count }, 4, 2],
      [Proc.new { ContentBlock.count }, 16, 8],
      [Proc.new { ResourceVersion.count }, 2, 1],
      [Proc.new { Quiz.count }, 2, 1],
      [Proc.new { QuizQuestion.count }, 2, 1],
      [Proc.new { AnswerOption.count }, 8, 4],
      [Proc.new { TimelineEvent.count }, 2, 1],
      [Proc.new { TimelineEventOwner.count }, 2, 1],
      [Proc.new { TimelineEventFile.count }, 2, 1],
      [Proc.new { StartupFeedback.count }, 2, 1],
      [Proc.new { ActsAsTaggableOn::Tagging.count }, 4, 2],
      [Proc.new { SubmissionComment.count }, 2, 1],
      [Proc.new { ModerationReport.count }, 2, 1],
      [Proc.new { Reaction.count }, 2, 1]
    ]
  end

  describe "#execute" do
    it "deletes all data related to the course and the course itself" do
      expect { subject.execute }.to(
        change { expectations.map { |e| e[0].call } }.from(
          expectations.pluck(1)
        ).to(expectations.pluck(2))
      )

      expect { course_2.reload }.not_to raise_error
      expect { level_c2.reload }.not_to raise_error
      expect { team_c2.reload }.not_to raise_error
      expect { student_c2.reload }.not_to raise_error
      expect { applicant_c2.reload }.not_to raise_error
      expect { certificate_c2.reload }.not_to raise_error
      expect { issued_certificate_c2.reload }.not_to raise_error
      expect { community_course_connection_c2.reload }.not_to raise_error
      expect { course_author_c2.reload }.not_to raise_error
      expect { course_export_c2.reload }.not_to raise_error
      expect { faculty_cohort_enrollment_c2.reload }.not_to raise_error
      expect { faculty_student_enrollment_c2.reload }.not_to raise_error
      expect { coach_note_c2.reload }.not_to raise_error
      expect { evaluation_criterion_c2.reload }.not_to raise_error
      expect { target_reviewed_c2.reload }.not_to raise_error
      expect { topic_c2.reload }.not_to raise_error
      expect { resource_version_c2.reload }.not_to raise_error
      expect { target_with_quiz_c2.reload }.not_to raise_error
      expect { submission_c2.reload }.not_to raise_error
      expect { submission_file_c2.reload }.not_to raise_error
      expect { feedback_c2.reload }.not_to raise_error
      expect { submission_comment_c2.reload }.not_to raise_error
      expect { moderation_report_c2.reload }.not_to raise_error
      expect { reaction_c2.reload }.not_to raise_error

      expect(topic_c1.reload.target_id).to eq(nil)
      expect(topic_c2.reload.target_id).to eq(target_reviewed_c2.id)
    end
  end
end
