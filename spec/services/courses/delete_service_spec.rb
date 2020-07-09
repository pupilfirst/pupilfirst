require 'rails_helper'

describe Courses::DeleteService do
  include SubmissionsHelper

  subject { described_class.new(course_1) }

  let(:common_coach) { create :faculty }
  let(:coach_c1) { create :faculty }
  let(:coach_c2) { create :faculty }

  # Course 1 - will be deleted.
  let(:course_1) { create :course, name: 'Course to delete' }
  let(:level_c1) { create :level, :one, course: course_1, name: 'C1L1' }
  let(:team_c1) { create :team, level: level_c1 }
  let(:student_c1) { create :student, startup: team_c1 }
  let!(:applicant_c1) { create :applicant, course: course_1 }
  let(:certificate_c1) { create :certificate, course: course_1 }
  let!(:issued_certificate_c1) { create :issued_certificate, certificate: certificate_c1 }
  let!(:community_course_connection_c1) { create :community_course_connection, course: course_1 }
  let!(:course_author_c1) { create :course_author, course: course_1 }
  let!(:course_export_c1) { create :course_export, :teams, course: course_1 }
  let!(:faculty_course_enrollment_c1) { create :faculty_course_enrollment, course: course_1, faculty: common_coach }
  let!(:faculty_startup_enrollment_c1) { create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_c1, startup: team_c1 }
  let!(:coach_note_c1) { create :coach_note, author: coach_c1.user, student: student_c1 }
  let(:evaluation_criterion_c1) { create :evaluation_criterion, course: course_1 }
  let(:target_reviewed_c1) { create :target, :with_content, :with_group, :with_default_checklist, level: level_c1, evaluation_criteria: [evaluation_criterion_c1] }
  let!(:topic_c1) { create :topic, :with_first_post, target: target_reviewed_c1, community: community_course_connection_c1.community }
  let!(:resource_version_c1) { create :resource_version, versionable: target_reviewed_c1 }
  let(:target_with_quiz_c1) { create :target, :with_content, target_group: target_reviewed_c1.target_group, prerequisite_targets: [target_reviewed_c1] }
  let!(:quiz_c1) { create :quiz, :with_question_and_answers, target: target_with_quiz_c1 }
  let!(:submission_c1) { complete_target(target_reviewed_c1, student_c1, evaluator: common_coach) }
  let!(:submission_file_c1) { create :timeline_event_file, timeline_event: submission_c1 }
  let!(:feedback_c1) { create :startup_feedback, startup: team_c1, faculty: common_coach, timeline_event: submission_c1 }

  # Course 2 - should be left untouched.
  let(:course_2) { create :course, name: 'Course to preserve' }
  let(:level_c2) { create :level, :one, course: course_2, name: 'C2L1' }
  let(:team_c2) { create :team, level: level_c2 }
  let(:student_c2) { create :student, startup: team_c2 }
  let!(:applicant_c2) { create :applicant, course: course_2 }
  let(:certificate_c2) { create :certificate, course: course_2 }
  let!(:issued_certificate_c2) { create :issued_certificate, certificate: certificate_c2 }
  let!(:community_course_connection_c2) { create :community_course_connection, course: course_2 }
  let!(:course_author_c2) { create :course_author, course: course_2 }
  let!(:course_export_c2) { create :course_export, :teams, course: course_2 }
  let!(:faculty_course_enrollment_c2) { create :faculty_course_enrollment, course: course_2, faculty: common_coach }
  let!(:faculty_startup_enrollment_c2) { create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_c2, startup: team_c2 }
  let!(:coach_note_c2) { create :coach_note, author: coach_c2.user, student: student_c2 }
  let(:evaluation_criterion_c2) { create :evaluation_criterion, course: course_2 }
  let(:target_reviewed_c2) { create :target, :with_content, :with_group, :with_default_checklist, level: level_c2, evaluation_criteria: [evaluation_criterion_c2] }
  let!(:topic_c2) { create :topic, :with_first_post, target: target_reviewed_c2, community: community_course_connection_c2.community }
  let!(:resource_version_c2) { create :resource_version, versionable: target_reviewed_c2 }
  let(:target_with_quiz_c2) { create :target, :with_content, target_group: target_reviewed_c2.target_group, prerequisite_targets: [target_reviewed_c2] }
  let!(:quiz_c2) { create :quiz, :with_question_and_answers, target: target_with_quiz_c2 }
  let!(:submission_c2) { complete_target(target_reviewed_c2, student_c2, evaluator: common_coach) }
  let!(:submission_file_c2) { create :timeline_event_file, timeline_event: submission_c2 }
  let!(:feedback_c2) { create :startup_feedback, startup: team_c2, faculty: common_coach, timeline_event: submission_c2 }

  before do
    # Tag the course exports.
    course_export_c1.tag_list.add('export tag c1')
    course_export_c1.save!
    course_export_c2.tag_list.add('export tag c2')
    course_export_c2.save!

    # Tag the teams.
    team_c1.tag_list.add('team tag c1')
    team_c1.save!
    team_c2.tag_list.add('team tag c2')
    team_c2.save!
  end

  let(:expectations) {
    [
      [Proc.new { Faculty.count }, 3, 3],
      [Proc.new { Course.count }, 2, 1],
      [Proc.new { Level.count }, 2, 1],
      [Proc.new { Startup.count }, 2, 1],
      [Proc.new { Founder.count }, 2, 1],
      [Proc.new { Applicant.count }, 2, 1],
      [Proc.new { Certificate.count }, 2, 1],
      [Proc.new { IssuedCertificate.count }, 2, 1],
      [Proc.new { CommunityCourseConnection.count }, 2, 1],
      [Proc.new { CourseAuthor.count }, 2, 1],
      [Proc.new { CourseExport.count }, 2, 1],
      [Proc.new { FacultyCourseEnrollment.count }, 4, 2],
      [Proc.new { FacultyStartupEnrollment.count }, 2, 1],
      [Proc.new { CoachNote.count }, 2, 1],
      [Proc.new { EvaluationCriterion.count }, 2, 1],
      [Proc.new { TimelineEventGrade.count }, 2, 1],
      [Proc.new { TargetEvaluationCriterion.count }, 2, 1],
      [Proc.new { TargetGroup.count }, 2, 1],
      [Proc.new { Target.count }, 4, 2],
      [Proc.new { TargetPrerequisite.count }, 2, 1],
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
    ]
  }

  describe '#execute' do
    it 'deletes all data related to the course and the course itself' do
      expect { subject.execute }.to(
        change {
          expectations.map { |e| e[0].call }
        }.from(
          expectations.map { |e| e[1] }
        ).to(
          expectations.map { |e| e[2] }
        )
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
      expect { faculty_course_enrollment_c2.reload }.not_to raise_error
      expect { faculty_startup_enrollment_c2.reload }.not_to raise_error
      expect { coach_note_c2.reload }.not_to raise_error
      expect { evaluation_criterion_c2.reload }.not_to raise_error
      expect { target_reviewed_c2.reload }.not_to raise_error
      expect { topic_c2.reload }.not_to raise_error
      expect { resource_version_c2.reload }.not_to raise_error
      expect { target_with_quiz_c2.reload }.not_to raise_error
      expect { quiz_c2.reload }.not_to raise_error
      expect { submission_c2.reload }.not_to raise_error
      expect { submission_file_c2.reload }.not_to raise_error
      expect { feedback_c2.reload }.not_to raise_error

      expect(topic_c1.reload.target_id).to eq(nil)
      expect(topic_c2.reload.target_id).to eq(target_reviewed_c2.id)
    end
  end
end
