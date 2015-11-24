require 'rails_helper'

RSpec.describe Resource, type: :model do
  subject { create :resource }

  let!(:tet_one_liner) { create :tet_one_liner }
  let!(:tet_new_product_deck) { create :tet_new_product_deck }
  let!(:tet_team_formed) { create :tet_team_formed }

  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }
  let!(:public_resource) { create :resource }
  let!(:approved_resource_for_all) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED }
  let!(:approved_resource_for_batch_1) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, shared_with_batch: 1 }
  let!(:approved_resource_for_batch_2) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, shared_with_batch: 2 }

  describe '.for' do
    context 'when user is not present' do
      it 'returns public resources' do
        resources = Resource.for(nil)

        expect(resources.count).to eq(1)
        expect(resources).to include(public_resource)
      end
    end

    context 'when user is founder of approved startup' do
      it 'returns public resources and shared resources for approved startups' do
        resources = Resource.for(startup.founders.first)

        expect(resources.count).to eq(2)
        expect(resources).to include(public_resource)
        expect(resources).to include(approved_resource_for_all)
      end
    end

    context 'when user is founder of batched startup' do
      let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED, batch_number: 1 }

      it 'returns public resources, shared resources and batch-specific resources for approved startups' do
        resources = Resource.for(startup.founders.first)

        expect(resources.count).to eq(3)
        expect(resources).to include(public_resource)
        expect(resources).to include(approved_resource_for_all)
        expect(resources).to include(approved_resource_for_batch_1)
      end
    end
  end

  describe '#for_approved?' do
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
