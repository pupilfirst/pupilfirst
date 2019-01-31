require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  permissions :connect? do
    let(:faculty) { create :faculty }
    let!(:connect_slot) { create :connect_slot, faculty: faculty, slot_at: 6.days.from_now }

    it 'denies access to public' do
      pundit_user = OpenStruct.new(current_user: nil)
      expect(subject).to_not permit(pundit_user, faculty)
    end

    context 'when startup does not have an active subscription' do
      let(:startup) { create :startup }

      it 'denies access to founder' do
        pundit_user = OpenStruct.new(current_user: startup.founders.first.user)
        expect(subject).to_not permit(pundit_user, faculty)
      end
    end

    context 'when startup has an active subscription' do
      let(:startup) { create :startup, :subscription_active }
      let(:pundit_user) { OpenStruct.new(current_user: startup.founders.first.user, current_founder: startup.founders.first) }

      it 'grants access to founder' do
        expect(subject).to permit(pundit_user, faculty)
      end

      context 'when faculty does not have available connect slots' do
        let!(:connect_request) { create :connect_request, connect_slot: connect_slot }

        it 'does not grant access to founder' do
          expect(subject).not_to permit(pundit_user, faculty)
        end
      end
    end
  end
end
