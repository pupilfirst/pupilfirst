require 'rails_helper'

describe Founders::AcceptInvitationService do
  include FounderSpecHelper

  subject { described_class.new(founder) }

  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition }
  let(:invited_startup) { create :level_0_startup }
  let(:founder) { create :founder, startup: original_startup, invited_startup: invited_startup }

  describe '#execute' do
    context 'when founder belongs to a startup that is level 1 or above' do
      let(:original_startup) { create :startup }

      it 'raises CannotAcceptInvitationException' do
        expect do
          Founders::AcceptInvitationService.new(founder).execute
        end.to raise_error(Founders::CannotAcceptInvitationException)
      end
    end

    context 'when founder does not belongs to a startup' do
      let(:original_startup) { nil }

      it 'accepts the invitation' do
        Founders::AcceptInvitationService.new(founder).execute
        expect(founder.reload.startup).to eq(invited_startup)
      end

      it 'confirms the user' do
        Founders::AcceptInvitationService.new(founder).execute
        expect(founder.reload.user.confirmed_at).to be_present
      end

      context 'when the invited startup is now beyond level 0' do
        let(:invited_startup) { create :startup }

        it 'accepts the invitation' do
          Founders::AcceptInvitationService.new(founder).execute
          expect(founder.reload.startup).to eq(invited_startup)
        end
      end
    end

    context 'when founder belongs to a startup at level 0' do
      let(:original_startup) { create :level_0_startup }

      context 'when original startup has remaining founders' do
        before do
          complete_target(founder, cofounder_addition_target)
        end

        context 'when founder was the admin' do
          before do
            original_startup.update!(team_lead: founder)
          end

          it 'preserves the startup with another founder as team lead' do
            Founders::AcceptInvitationService.new(founder).execute
            expect(original_startup.reload.team_lead).to_not eq(founder)
          end
        end

        context 'when number of billable founders in old startup drops to one' do
          it 'resets the cofounder addition target' do
            expect do
              Founders::AcceptInvitationService.new(founder).execute
            end.to change {
              TimelineEvent.where(
                startup: original_startup,
                target: cofounder_addition_target,
                status: TimelineEvent::STATUS_VERIFIED
              ).count
            }.from(1).to(0)
          end
        end
      end

      context 'when original startup becomes empty' do
        before do
          # Get rid of the additional founder from original startup.
          original_startup.update!(team_lead: founder)
          original_startup.founders.where.not(id: founder.id).delete_all
        end

        context 'when original startup had invitees' do
          let!(:another_invited_founder) { create :founder, invited_startup: original_startup }

          it 'wipes all invitations' do
            Founders::AcceptInvitationService.new(founder).execute
            expect(another_invited_founder.reload.invited_startup).to eq(nil)
          end
        end

        it 'deletes the original startup' do
          Founders::AcceptInvitationService.new(founder).execute
          expect(Startup.find_by(id: original_startup.id)).to be_nil
        end
      end
    end
  end
end
