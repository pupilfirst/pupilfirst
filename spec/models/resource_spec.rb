require 'rails_helper'

RSpec.describe Resource, type: :model do
  subject { create :resource }

  describe '.for_approved?' do
    context 'when share_status is public' do
      it 'returns false' do
        expect(subject.for_approved?).to be_falsey
      end
    end

    context 'when share status is approved' do
      subject { create :resource, share_status: Resource::SHARE_STATUS_APPROVED }

      it 'returns true' do
        expect(subject.for_approved?).to be_truthy
      end
    end
  end
end
