require 'rails_helper'

describe ResourcePolicy do
  subject { described_class }

  let(:level_0) { create :level, :zero }
  let(:level_1) { create :level, :one }
  let(:level_2) { create :level, :two }

  let(:startup) { create :startup, :subscription_active }
  let(:founder) { startup.founders.where.not(id: startup.team_lead_id).first }

  let!(:public_resource) { create :resource }
  let!(:level_0_resource) { create :resource, level: level_0 }
  let!(:level_1_resource) { create :resource, level: level_1 }
  let!(:level_2_resource) { create :resource, level: level_2 }

  permissions :show? do
    context 'when founder belongs to level 1 approved startup' do
      it 'allows access to public resource' do
        expect(subject).to permit(founder.user, public_resource)
      end

      it 'allows access to resources upto level 1' do
        expect(subject).to permit(founder.user, level_0_resource)
        expect(subject).to permit(founder.user, level_1_resource)
        expect(subject).to_not permit(founder.user, level_2_resource)
      end
    end

    context 'when founder belongs to dropped out startup' do
      before do
        startup.update!(dropped_out: true)
      end

      it 'allows access to public resource' do
        expect(subject).to permit(founder.user, public_resource)
      end

      it 'denies access to all approved resources' do
        expect(subject).to_not permit(founder.user, level_0_resource)
        expect(subject).to_not permit(founder.user, level_1_resource)
        expect(subject).to_not permit(founder.user, level_2_resource)
      end
    end

    context "when the founder's subscription is inactive" do
      let(:startup) { create :startup }

      it 'allows access to public resource' do
        expect(subject).to permit(founder.user, public_resource)
      end

      it 'denies access to all approved resources' do
        expect(subject).to_not permit(founder.user, level_0_resource)
        expect(subject).to_not permit(founder.user, level_1_resource)
        expect(subject).to_not permit(founder.user, level_2_resource)
      end
    end
  end
end
