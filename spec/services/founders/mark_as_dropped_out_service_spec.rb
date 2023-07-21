require "rails_helper"

describe Students::MarkAsDroppedOutService do
  subject { described_class.new(student, user) }

  let(:user) { create :user }

  describe "#execute" do
    context "when the student is in a team of more than one"
    let(:cohort) { create :cohort }
    let(:original_team) { create :team_with_students, cohort: cohort }
    let(:student) { original_team.students.first }

    it 'removes the team link and mark the student as exited' do
      expect { subject.execute }.to change { student.reload.dropped_out_at }
        .from(nil)
      expect(student.team).to eq(nil)

      # Check audit records
      audit_record = AuditRecord.last
      expect(audit_record.audit_type).to eq(
        AuditRecord.audit_types[:dropout_student]
      )
      expect(audit_record.school_id).to eq(user.school.id)
      expect(audit_record.metadata["user_id"]).to eq(user.id)
      expect(audit_record.metadata["email"]).to eq(student.email)
    end
  end

  context "when the student is alone in a team" do
    let(:cohort) { create :cohort }
    let(:team) { create :team, cohort: cohort }
    let(:student) { create :student, team: team, cohort: cohort }
    let(:coach) { create :faculty, school: cohort.school }

    before do
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: coach,
             student: student
    end

    it "marks the student as exited and removes all direct coach enrollments to the team" do
      team_id = team.id
      expect(student.team).to eq(team)

      expect { subject.execute }.to change { student.faculty.count }.from(1).to(
        0
      )

      # The student should be destroyed.
      expect(student.reload.team).to eq(nil)
      expect(Team.find_by(id: team_id)).to eq(nil)
      expect(student.dropped_out_at).not_to eq(nil)
    end
  end
end
