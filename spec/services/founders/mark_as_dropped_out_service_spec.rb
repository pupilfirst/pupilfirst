require 'rails_helper'

describe Founders::MarkAsDroppedOutService do
  subject { described_class.new(student, user) }

  let(:user) { create :user }

  describe '#execute' do
    context 'when the student is in a team of more than one'
    let(:original_team) { create :startup, tag_list: %w[tag_a tag_b] }
    let(:student) { original_team.founders.first }

    it 'creates a new startup in the same level and mark the founder as exited' do
      expect { subject.execute }.to change { student.reload.startup.dropped_out_at }.from(nil)
      expect(student.startup.id).not_to eq(original_team.id)
      expect(student.startup.tag_list).to match_array(%w[tag_a tag_b])

      # Check audit records
      audit_record = AuditRecord.last
      expect(audit_record.audit_type).to eq(AuditRecord::TYPE_DROPOUT_STUDENT)
      expect(audit_record.school_id).to eq(user.school.id)
      expect(audit_record.metadata['user_id']).to eq(user.id)
      expect(audit_record.metadata['email']).to eq(student.email)
    end
  end

  context 'when the student is alone in a team' do
    let(:team) { create :team }
    let(:student) { create :founder, startup: team }
    let(:coach) { create :faculty, school: team.school }

    before do
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach, startup: team
    end

    it 'marks the student as exited and removes all direct coach enrollments to the team' do
      expect { subject.execute }.to change { team.faculty.count }.from(1).to(0)

      # The student should be in the same team.
      expect(student.reload.startup).to eq(team)
      expect(student.startup.dropped_out_at).not_to eq(nil)
    end
  end
end
