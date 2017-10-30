require 'rails_helper'

describe Founders::RemoveFromStartupService do
  subject { described_class.new(founder) }

  let!(:startup) { create :startup }
  let(:founder) { startup.team_lead }
  let(:founder_2) { startup.founders.where.not(id: founder.id).first }

  describe '#execute' do
    context 'when the startup has a second co-founder' do
      it 'removes the founder from the startup after re-assigning team lead' do
        subject.execute
        expect(startup.reload.team_lead).to eq(founder_2)
        expect(founder.reload.startup).to eq(nil)
      end
    end

    context 'when the startup only has a single founder' do
      before do
        # Remove the second founder from the startup
        founder_2.update!(startup: nil)
      end

      it 'raises exception' do
        expect { subject.execute }.to raise_error(Founders::RemoveFromStartupService::NoOtherFoundersInStartupException)
      end
    end
  end
end
