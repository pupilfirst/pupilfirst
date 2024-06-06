require 'rails_helper'

RSpec.describe Students::ResetProgressService do
  let(:student) { create(:student) }
  let(:executor) { create(:user) }
  let(:service) { Students::ResetProgressService.new(student, executor) }

  describe '#reset' do
    context 'when the student has submissions' do
      let!(:submission) { create(:timeline_event, :with_owners, latest: true, owners: [student]) }

      it 'archives the submissions' do
        expect(submission.timeline_event_owners.all?(&:latest)).to be_truthy

        service.reset
        expect(submission.reload.archived_at).not_to be_nil
        expect(submission.timeline_event_owners.all?(&:latest)).to be_falsey
      end

      context 'when the submission has multiple owners' do
        let!(:another_student) { create(:student) }
        let!(:another_owner) { create(:timeline_event_owner, timeline_event: submission, student: another_student) }

        it 'does not archive the submission' do
          service.reset
          expect(submission.reload.archived_at).to be_nil
        end
      end
    end

    context 'when the student has page reads' do
      let!(:page_read) { create(:page_read, student: student) }

      it 'deletes all page reads' do
        service.reset
        expect(student.page_reads).to be_empty
      end
    end

    it 'resets the completed_at timestamp' do
      student.update!(completed_at: Time.zone.now)
      service.reset
      expect(student.reload.completed_at).to be_nil
    end

    it 'adds a coach note indicating the reset' do
      expect { service.reset }.to change { student.coach_notes.count }.from(0).to(1)
      expect(student.coach_notes.last.note).to eq("The progress for this student has been reset based on the request from the student.")
      expect(student.coach_notes.last.author).to eq(executor)
    end
  end
end
