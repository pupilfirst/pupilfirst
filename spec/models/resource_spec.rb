require 'rails_helper'

RSpec.describe Resource, type: :model do
  subject { create :resource }

  before :all do
    PublicSlackTalk.mock = true
  end

  after :all do
    PublicSlackTalk.mock = false
  end

  let(:startup_1) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }
  let(:startup_2) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }
  let!(:public_resource) { create :resource }

  let(:batch_1) { create :batch }
  let(:batch_2) { create :batch }

  let!(:approved_resource_for_all) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED }
  let!(:approved_resource_for_batch_1) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, batch: batch_1 }
  let!(:approved_resource_for_batch_2) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, batch: batch_2 }
  let!(:approved_resource_for_startup_1) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, startup: startup_1 }
  let!(:approved_resource_for_startup_2) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, startup: startup_2 }

  describe '.for' do
    context 'when founder is not present' do
      it 'returns public resources' do
        resources = Resource.for(nil)

        expect(resources.count).to eq(1)
        expect(resources).to include(public_resource)
      end
    end

    context 'when founder is founder of a approved startup' do
      it 'returns public resources and shared resources for the approved startup' do
        resources = Resource.for(startup_1.founders.first)

        expect(resources.count).to eq(3)
        expect(resources).to include(public_resource)
        expect(resources).to include(approved_resource_for_all)
        expect(resources).to include(approved_resource_for_startup_1)
        expect(resources).not_to include(approved_resource_for_startup_2)
      end
    end

    context 'when founder is founder of batched startup' do
      let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED, batch: batch_1 }

      it 'returns public resources, shared resources and batch-specific resources for approved startups' do
        resources = Resource.for(startup.founders.first)

        expect(resources.count).to eq(3)
        expect(resources).to include(public_resource)
        expect(resources).to include(approved_resource_for_all)
        expect(resources).to include(approved_resource_for_batch_1)
        expect(resources).not_to include(approved_resource_for_batch_2)
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
