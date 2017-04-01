require 'rails_helper'

describe Startups::LevelUpService do
  subject { described_class.new(startup) }

  let!(:level_1) { create :level, :one }
  let!(:level_2) { create :level, :two }
  let!(:level_5) { create :level, :five }

  describe '#execute' do
    context 'when the startup is at maximum level' do
      let(:startup) { create :startup, level: level_5 }

      it 'raises error' do
        expect { subject.execute }.to raise_error 'Maximum level reached - cannot level up.'
      end
    end

    context 'when startup is at level 1' do
      let(:startup) { create :startup, level: level_1 }

      it "raises startup's level to 2" do
        expect { subject.execute }.to change { startup.reload.level }.from(level_1).to(level_2)
      end
    end
  end
end
