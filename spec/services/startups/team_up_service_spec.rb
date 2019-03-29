require 'rails_helper'

describe Startups::TeamUpService do
  subject { described_class.new(founders) }

  let(:startup_1) { create :startup }
  let(:startup_2) { create :startup }

  let(:founder_1) { startup_1.founders.first }
  let(:founder_2) { startup_1.founders.second }
  let(:founder_3) { startup_2.founders.first }
  let(:founder_4) { startup_2.founders.second }

  let!(:founders) { Founder.where(id: [founder_1.id, founder_2.id, founder_3.id, founder_4.id]) }
  let(:team_name) { Faker::Lorem.words(2).join(' ') }

  describe '#team_up' do
    it 'forms a new team with specified founders' do
      expect { subject.team_up(team_name) }.to(change { Startup.count }.from(2).to(1))

      last_startup = Startup.last

      # New startup has expected properties.
      expect(last_startup.founders.pluck(:id)).to eq(founders.pluck(:id))
      expect(last_startup.name).to eq(team_name)

      expect(founder_1.reload.startup.founders.count).to eq(4)
    end
  end
end
