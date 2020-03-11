require 'rails_helper'

describe Founders::MarkAsDroppedOutService do
  subject { described_class.new(student) }

  describe '#execute' do
    context 'when the student is in a team of more than one'
    let(:student) { create :founder }

    it 'creates a new startup in the same level and mark the founder as exited' do
      old_startup = student.startup

      expect { subject.execute }.to change { student.reload.startup.dropped_out_at }.from(nil)
      expect(student.startup.id).not_to eq(old_startup.id)
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
