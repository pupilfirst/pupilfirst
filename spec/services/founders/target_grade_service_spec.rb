require 'rails_helper'

describe Founders::TargetGradeService do
  subject { described_class.new(founder) }

  let(:level_zero) { create :level, :zero }
  let!(:startup) { create :startup, level: level_zero }
  let(:founder) { create :founder }
  let(:co_founder) { create :founder }

  let!(:target_group) { create :target_group, level: level_zero }
  let!(:founder_target) { create :target, :for_founders, target_group: target_group }
  let!(:startup_target) { create :target, :for_startup, target_group: target_group }

  let!(:founder_event) do
    create :timeline_event,
      founder: founder,
      startup: startup,
      target: founder_target,
      status: TimelineEvent::STATUS_VERIFIED,
      score: 3.0
  end

  let!(:co_founder_event) do
    create :timeline_event,
      founder: co_founder,
      startup: startup,
      target: startup_target,
      status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT
  end

  before do
    startup.founders << [founder, co_founder]
  end

  describe '#grade' do
    it 'returns the grade of the specified target' do
      expect(subject.grade(founder_target.id)).to eq(TimelineEvent::GRADE_WOW)
      expect(subject.score(founder_target.id)).to eq(3.0)
      expect(subject.grade(startup_target.id)).to eq(nil)
      expect(subject.score(startup_target.id)).to eq(nil)
    end
  end
end
