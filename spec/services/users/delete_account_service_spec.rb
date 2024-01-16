require "rails_helper"

describe Users::DeleteAccountService do
  subject { described_class.new(user) }

  # Setup the basics
  let(:organisation) { create :organisation }
  let(:user) do
    create :user,
           account_deletion_notification_sent_at: 2.days.ago,
           school: organisation.school,
           organisation: organisation
  end

  let!(:student) { create :student, user: user }
  let!(:student_2) { create :student, user: user }

  let!(:team) { create :team_with_students }

  let!(:coach) { create :faculty, user: user }
  let!(:course) { create :course, :with_cohort, school: user.school }
  let!(:course_author) { create :course_author, user: user, course: course }

  # Coach notes for the student profiles
  let!(:coach_note_1) { create :coach_note, student: student }

  # Create submissions by the student profile
  let(:course_1) { create :course, school: user.school }
  let(:level_1) { create :level, :one, course: course_1 }
  let(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_1
  end
  let!(:target_2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_TEAM,
           target_group: target_group_1
  end
  let!(:submission_by_student) do
    create :timeline_event,
           :with_owners,
           latest: true,
           owners: [student],
           target: target_1
  end
  let!(:submission_by_team) do
    create :timeline_event,
           :with_owners,
           latest: true,
           owners: team.students,
           target: target_1
  end

  # Create coach enrollments, startup feedback, evaluated submissions and coach notes by user
  let!(:coach_cohort_enrollment) do
    create :faculty_cohort_enrollment,
           cohort: course.cohorts.first,
           faculty: coach
  end
  let!(:team_2) { create :team_with_students }
  let!(:coach_student_enrollment) do
    create :faculty_student_enrollment,
           student: team_2.students.first,
           faculty: coach
  end
  let!(:coach_note_by_user) do
    create :coach_note, author: user, student: team_2.students.first
  end
  let!(:submission_reviewed_by_user) do
    create :timeline_event,
           :with_owners,
           latest: true,
           owners: team_2.students,
           target: target_1,
           evaluator: coach,
           evaluated_at: Time.zone.now
  end

  # Create community records
  let!(:post) { create :post, creator: user, topic: create(:topic) }
  let!(:post_like) { create :post_like, user: user, post: post }

  # Miscellaneous records
  let!(:issued_certificate_for_user) { create :issued_certificate, user: user }
  let!(:markdown_attachment_by_user) { create :markdown_attachment, user: user }
  let!(:course_export) do
    create :course_export, :teams, user: user, course: course
  end

  # Setup for submission with multiple owners and file uploads
  let!(:other_student) { create :student, school: user.school }
  let!(:shared_submission) do
    create :timeline_event,
           :with_owners,
           latest: true,
           owners: [student, other_student],
           target: target_2
  end
  let!(:shared_submission_file) do
    create :timeline_event_file, timeline_event: shared_submission, user: user
  end

  describe "#execute" do
    context "user is an admin in school" do
      before { create(:school_admin, user: user, school: user.school) }
      it "an exception is raised" do
        expect { subject.execute }.to raise_error("user is a school admin")
      end
    end

    context "user is not an admin in school" do
      before do
        post.text_versions.create!(
          value: post.body,
          user: user,
          edited_at: post.updated_at
        )
      end
      it "deletes data and nullifies references in applicable records" do
        subject.execute

        # Check only applicable records are destroyed
        expect(User.find_by(id: user.id)).to eq(nil)
        expect(Student.find_by(id: student.id)).to eq(nil)
        expect(Team.find_by(id: team.id)).to_not eq(nil)
        expect(
          TimelineEventOwner.where(student_id: user.students.select(:id))
        ).to eq([])
        expect(TimelineEvent.find_by(id: submission_by_student.id)).to eq(nil)
        expect(TimelineEvent.find_by(id: submission_by_team.id)).to_not eq(nil)
        expect(submission_by_team.students.pluck(:id).sort).to eq(
          team.students.reload.pluck(:id).sort
        )
        expect(CourseAuthor.find_by(id: course_author.id)).to eq(nil)
        expect(Faculty.find_by(id: coach.id)).to eq(nil)
        expect(CoachNote.find_by(id: coach_note_1.id)).to eq(nil)
        expect(
          FacultyCohortEnrollment.find_by(id: coach_cohort_enrollment.id)
        ).to eq(nil)
        expect(
          FacultyStudentEnrollment.find_by(id: coach_student_enrollment.id)
        ).to eq(nil)

        # Check user_id is nullified in applicable records
        expect(coach_note_by_user.reload.author_id).to eq(nil)
        expect(submission_reviewed_by_user.reload.evaluator_id).to eq(nil)
        expect(post.reload.creator_id).to eq(nil)
        expect(post_like.reload.user_id).to eq(nil)
        expect(post.text_versions.first.user_id).to eq(nil)
        expect(issued_certificate_for_user.reload.user_id).to eq(nil)
        expect(markdown_attachment_by_user.reload.user_id).to eq(nil)
        expect(course_export.reload.user_id).to eq(nil)

        # Ensure shared submission still exists
        expect(TimelineEvent.find_by(id: shared_submission.id)).to_not eq(nil)

        # Check that the user_id of the timeline event files has been updated
        shared_submission.timeline_event_files.each do |file|
          expect(file.user_id).to eq(other_student.user_id)
        end

        # Check audit record is created
        audit_record = AuditRecord.last
        expect(audit_record.audit_type).to eq(
          AuditRecord.audit_types[:delete_account]
        )
        expect(audit_record.metadata["name"]).to eq(user.name)
        expect(audit_record.metadata["email"]).to eq(user.email)
        expect(
          audit_record.metadata["account_deletion_notification_sent_at"]
        ).to eq(user.account_deletion_notification_sent_at.iso8601)

        expect(audit_record.metadata["cohort_ids"]).to match_array(
          [student.cohort_id, student_2.cohort_id]
        )
        expect(audit_record.metadata["organisation_id"]).to eq(organisation.id)
      end
    end
  end
end
