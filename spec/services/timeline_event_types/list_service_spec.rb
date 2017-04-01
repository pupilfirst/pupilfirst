require 'rails_helper'

describe TimelineEventTypes::ListService do
  subject { described_class.new(startup) }

  let(:startup) { create :startup }

  let!(:te_suggested_1) { create :timeline_event_type, suggested_stage: TimelineEventType::TYPE_STAGE_IDEA, role: TimelineEventType::ROLE_FOUNDER }
  let!(:te_suggested_2) { create :timeline_event_type, suggested_stage: TimelineEventType::TYPE_STAGE_IDEA, role: TimelineEventType::ROLE_TEAM }
  let!(:te_suggested_3) { create :timeline_event_type, suggested_stage: TimelineEventType::TYPE_STAGE_PROTOTYPE, role: TimelineEventType::ROLE_TEAM }
  let!(:te_suggested_4) { create :timeline_event_type, suggested_stage: TimelineEventType::TYPE_STAGE_CUSTOMER, role: TimelineEventType::ROLE_TEAM }
  let!(:te_suggested_5) { create :timeline_event_type, suggested_stage: TimelineEventType::TYPE_STAGE_EFFICIENCY, role: TimelineEventType::ROLE_ENGINEERING }
  let!(:te_suggested_6) { create :timeline_event_type, suggested_stage: TimelineEventType::TYPE_STAGE_EFFICIENCY, role: TimelineEventType::ROLE_DESIGN }
  let!(:te_suggested_7) { create :timeline_event_type, suggested_stage: TimelineEventType::TYPE_STAGE_CUSTOMER, role: TimelineEventType::ROLE_FOUNDER }

  let(:te_founder_email_verification) { TimelineEventType.find_by(key: TimelineEventType::TYPE_FOUNDER_UPDATE) }

  describe '#list' do
    it 'returns grouped list of timeline events' do
      expected_return = {
        'Suggested' => {
          te_suggested_1.id => {
            title: te_suggested_1.title,
            sample: te_suggested_1.sample
          },
          te_suggested_2.id => {
            title: te_suggested_2.title,
            sample: te_suggested_2.sample
          }
        },
        'Team' => {
          te_suggested_3.id => {
            title: te_suggested_3.title,
            sample: te_suggested_3.sample
          },
          te_suggested_4.id => {
            title: te_suggested_4.title,
            sample: te_suggested_4.sample
          }
        },
        'Engineering' => {
          te_suggested_5.id => {
            title: te_suggested_5.title,
            sample: te_suggested_5.sample
          }
        },
        'Design' => {
          te_suggested_6.id => {
            title: te_suggested_6.title,
            sample: te_suggested_6.sample
          }
        },
        'Founder' => {
          te_suggested_7.id => {
            title: te_suggested_7.title,
            sample: te_suggested_7.sample
          },
          te_founder_email_verification.id => {
            title: te_founder_email_verification.title,
            sample: te_founder_email_verification.sample
          }
        }
      }

      expect(subject.list).to eq(expected_return)
    end
  end
end
