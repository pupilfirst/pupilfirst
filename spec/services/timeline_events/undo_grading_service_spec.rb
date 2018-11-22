require 'rails_helper'

describe TimelineEvents::UndoGradingService do
  subject { described_class.new(timeline_event) }

  let(:target) { create :target }
  let(:startup) { create :startup }
  let(:founder) { create :founder, startup: startup }
  let(:faculty) { create :faculty }
  let(:school) { create :school }
  let(:timeline_event) { create :timeline_event, target: target, startup: startup, founder: founder }
  let(:target_with_evaluation_criteria) { create :target }
  let!(:evaluation_criterion_1) { create :evaluation_criterion, school: school }
  let!(:evaluation_criterion_2) { create :evaluation_criterion, school: school }

  before do
    target.evaluation_criteria << [evaluation_criterion_1, evaluation_criterion_2]
  end

  describe '#execute' do
    context 'when the timeline event was reviewed before' do
      before do
        timeline_event.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_1, grade: 2)
        timeline_event.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_2, grade: 3)
        timeline_event.update!(evaluator: faculty, passed_at: 2.days.ago)
      end
      it 'deletes awarded grades for all evaluation criteria and clears evaluation info' do
        subject.execute
        expect(TimelineEventGrade.where(timeline_event: timeline_event).count).to eq(0)
        expect(timeline_event.passed_at).to eq(nil)
        expect(timeline_event.evaluator_id).to eq(nil)
      end
    end

    context 'when the timeline event was not reviewed before' do
      it 'raises a pending review exception' do
        expect { subject.execute }.to raise_error(TimelineEvents::GradingService::ReviewPendingException)
      end
    end
  end
end
