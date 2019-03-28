require 'rails_helper'

describe Founders::MarkAsExitedService do
  subject { described_class.new(founder.id) }
  let(:founder) { create :founder }

  describe '#execute' do
    context 'when a founder is archived' do
      it 'creates a new startup in the same level and mark the founder as exited' do
        old_startup = founder.startup

        expect { subject.execute }.to change { founder.reload.exited }.from(false).to(true)
        expect(founder.startup.id).not_to eq(old_startup.id)
      end
    end
  end
end
