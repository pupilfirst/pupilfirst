require 'rails_helper'

describe Targets::BulkGradeService do
  subject { described_class.new(founder) }

  let(:level_zero) { create :level, :zero }
  let!(:startup) { create :startup, level: level_zero }
  let(:founder) { create :founder }
  let(:co_founder) { create :founder }

  let!(:target_group) { create :target_group, level: level_zero }
  let!(:founder_target) { create :target, :for_founders, target_group: target_group }
  let!(:startup_target) { create :target, :for_startup, target_group: target_group }
  let!(:founder_chore) { create :target, target_group: nil, chore: true, level: level_zero }

  let!(:founder_event) do
    create :timeline_event,
      founder: founder,
      startup: startup,
      target: founder_target,
      verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED,
      grade: TimelineEvent::GRADE_WOW
  end
  let!(:founder_event_2) do
    create :timeline_event,
      founder: founder,
      startup: startup,
      target: founder_chore,
      verified_status: TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED
  end

  let!(:co_founder_event) do
    create :timeline_event,
      founder: co_founder,
      startup: startup,
      target: startup_target,
      verified_status: TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT
  end

  before do
    startup.founders << [founder, co_founder]
  end

  describe '#grades' do
    it 'returns grades of all verified/needs_improvement events' do
      expected_grades = {
        founder_target.id => {
          grade: TimelineEvent::GRADE_WOW,
          event_id: founder_event.id
        },
        startup_target.id => {
          grade: nil,
          event_id: co_founder_event.id
        }
      }

      expect(subject.grades).to eq(expected_grades)
    end
  end
end
