require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  # This policy relies on being supplied a `current_user`, which would have `current_founder` set.
  def current_user(founder)
    founder.user.tap { |user| user.current_founder = founder }
  end

  permissions :connect? do
    let(:faculty) { create :faculty }
    let!(:connect_slot) { create :connect_slot, faculty: faculty, slot_at: 6.days.from_now }

    it 'denies access to public' do
      expect(subject).to_not permit(nil, faculty)
    end

    context 'when startup has founders' do
      let(:startup) { create :startup }

      it 'grants access to founder' do
        expect(subject).to permit(current_user(startup.founders.first), faculty)
      end

      context 'when faculty does not have available connect slots' do
        let!(:connect_request) { create :connect_request, connect_slot: connect_slot }

        it 'does not grant access to founder' do
          expect(subject).not_to permit(current_user(startup.founders.first), faculty)
        end
      end
    end
  end
end
