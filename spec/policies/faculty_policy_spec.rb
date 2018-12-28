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

    context 'when startup does not have an active subscription' do
      let(:startup) { create :startup }

      it 'denies access to founder' do
        expect(subject).to_not permit(current_user(startup.team_lead), faculty)
      end
    end

    context 'when startup has an active subscription' do
      let(:startup) { create :startup, :subscription_active }

      before do
        create :founder, startup: startup
      end

      it 'grants access to team-lead from active startup' do
        expect(subject).to permit(current_user(startup.team_lead), faculty)
      end

      it 'grants access to non-team-lead from active startup' do
        non_team_lead = startup.founders.find { |founder| !founder.team_lead? }
        expect(subject).to permit(current_user(non_team_lead), faculty)
      end

      context 'when faculty does not have available connect slots' do
        let!(:connect_request) { create :connect_request, connect_slot: connect_slot }

        it 'does not grant access to founder' do
          expect(subject).not_to permit(current_user(startup.team_lead), faculty)
        end
      end
    end
  end
end
