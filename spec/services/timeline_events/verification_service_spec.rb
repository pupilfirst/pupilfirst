require 'rails_helper'

describe TimelineEvents::VerificationService do
  subject { described_class.new(timeline_event) }

  let(:timeline_event) { create :timeline_event }
  let(:timeline_event_2) { create :timeline_event, status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT }
  let(:karma_point) { create :karma_point, points: 10 }
  let(:target) { create :target, points_earnable: 10 }
  let(:startup) { create :startup }
  let(:founder) { create :founder, startup: startup }
  let(:tet_founder_update) { create :timeline_event_type, :founder_update }
  let(:tet_team_update) { create :timeline_event_type, :team_update }
  let(:target_with_skills) { create :target }
  let!(:skill_1) { create :skill }
  let!(:skill_2) { create :skill }
  let!(:target_skill_1) { create :target_skill, target: target_with_skills, skill: skill_1, base_karma_points: 20 }
  let!(:target_skill_2) { create :target_skill, target: target_with_skills, skill: skill_2, base_karma_points: 30 }

  before do
    # stub out vocalist notifications
    allow(TimelineEvents::VerificationNotificationJob).to receive(:perform_later).and_return(true)
  end

  describe '#update_status' do
    context 'when the timeline event is not associated to a target' do
      context 'when asked to mark event as verified' do
        it 'marks the event verified and adds appropriate karma points' do
          subject.update_status(TimelineEvent::STATUS_VERIFIED, points: 10)

          timeline_event.reload
          expect(timeline_event.verified?).to eq(true)
          expect(timeline_event.karma_point.points).to eq(10)
        end
      end

      context 'when asked to mark event as not accepted' do
        it 'marks the event not accepted and deletes associated karma point' do
          subject.update_status(TimelineEvent::STATUS_NOT_ACCEPTED)

          timeline_event.reload
          expect(timeline_event.not_accepted?).to eq(true)
          expect(timeline_event.karma_point).to eq(nil)
        end
      end
    end

    context 'when the timeline event is associated with a target without PC' do
      before do
        timeline_event.update!(target: target, founder: founder, startup: startup)
      end

      context 'when asked to mark event as verified and graded as wow' do
        it 'marks the event verified and adds appropriate karma points' do
          subject.update_status(TimelineEvent::STATUS_VERIFIED, grade: TimelineEvent::GRADE_WOW)

          timeline_event.reload
          expect(timeline_event.verified?).to eq(true)
          expect(timeline_event.score).to eq(3.0)
          expect(timeline_event.karma_point.points).to eq(20)
        end
      end

      context 'when asked to mark event as needs improvement' do
        it 'marks the event as needs improvement without awarding karma points' do
          subject.update_status(TimelineEvent::STATUS_NEEDS_IMPROVEMENT)

          timeline_event.reload
          expect(timeline_event.needs_improvement?).to eq(true)
          expect(timeline_event.karma_point).to eq(nil)
        end
      end

      context 'when asked to mark event as verified and the target had an earlier needs-improvement event' do
        before do
          timeline_event_2.update!(target: target, founder: founder, startup: startup)
          karma_point.update!(source: timeline_event_2)
        end
        it 'marks the event as verified/wow awards karma points per the grade' do
          subject.update_status(TimelineEvent::STATUS_VERIFIED, grade: TimelineEvent::GRADE_WOW)

          timeline_event.reload
          expect(timeline_event.verified?).to eq(true)
          expect(timeline_event.karma_point.points).to eq(20)
        end
      end

      context 'when a founder timeline event is verified' do
        it 'does not update the startups timeline_updated_on' do
          timeline_event.update!(timeline_event_type: tet_founder_update)
          subject.update_status(TimelineEvent::STATUS_VERIFIED, points: 10)

          expect(timeline_event.startup.timeline_updated_on).to eq(nil)
        end
      end

      context 'when a team timeline event is verified' do
        it 'updates the startups timeline_updated_on' do
          timeline_event.update!(timeline_event_type: tet_team_update)
          subject.update_status(TimelineEvent::STATUS_VERIFIED, points: 10)

          expect(timeline_event.startup.timeline_updated_on).to eq(timeline_event.event_on)
        end
      end
    end

    context 'when the timeline event is associated with a target with PC' do
      before do
        timeline_event.update!(target: target_with_skills, founder: founder, startup: startup)
      end

      context 'when asked to mark event as needs improvement' do
        it 'marks the event as needs improvement without awarding karma points' do
          subject.update_status(TimelineEvent::STATUS_NEEDS_IMPROVEMENT)

          timeline_event.reload
          expect(timeline_event.needs_improvement?).to eq(true)
          expect(timeline_event.karma_point).to eq(nil)
        end
      end

      context 'when asked to mark event as verified and graded as PC1 = wow and PC2 = great' do
        it 'marks the event verified and adds appropriate karma points' do
          subject.update_status(TimelineEvent::STATUS_VERIFIED, skill_grades: { skill_1.id.to_s => TimelineEvent::GRADE_WOW, skill_2.id.to_s => TimelineEvent::GRADE_GREAT })

          timeline_event.reload
          expect(timeline_event.verified?).to eq(true)
          expect(timeline_event.score).to eq(2.5)
          expect(timeline_event.karma_point.points).to eq(85)
        end
      end
    end
  end
end
