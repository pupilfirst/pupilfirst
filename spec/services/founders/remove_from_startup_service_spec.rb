require 'rails_helper'

describe Founders::RemoveFromStartupService do
  subject { described_class.new(founder) }

  let!(:startup) { create :startup }
  let(:founder) { startup.founders.first }
  let(:founder_2) { startup.founders.where.not(id: founder.id).first }

  describe '#execute' do
    context 'when the team has more than one student' do
      it 'marks the student as exited' do
        expect { subject.execute }.to(change { founder.reload.exited }.from(false).to(true))
      end
    end

    context 'when the team only has a single student' do
      before do
        # Remove the second team member.
        founder_2.destroy
      end

      it 'raises exception' do
        expect { subject.execute }.to raise_error(Founders::RemoveFromStartupService::NoOtherFoundersInStartupException)
      end
    end
  end
end
