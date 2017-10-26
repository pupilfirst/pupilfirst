require 'rails_helper'

describe PublicSlack::PruneMembershipService do
  subject { described_class.new }

  let!(:startup) { create :startup, :subscription_active }
  let(:mock_api_service) { instance_double PublicSlack::ApiService }
  let(:group_ids) { { 'groups' => [{ 'id' => 'group_id_1' }, { 'id' => 'group_id_2' }] } }
  let(:ok_response) { { 'ok' => true } }
  let(:mock_message_service) { instance_double PublicSlack::MessageService }

  let(:not_in_group_exception) do
    PublicSlack::OperationFailureException.new('_error_message', 'error' => 'not_in_group')
  end

  describe '.execute' do
    context 'when there are no founders to be pruned' do
      it 'does nothing' do
        expect(PublicSlack::ApiService).to_not receive(:new)
        subject.execute
      end
    end

    context 'when there is an expired founder in pruning region' do
      before do
        # Expire the startup subscription.
        startup.payments.last.update!(billing_start_at: 4.weeks.ago, billing_end_at: 4.days.ago)

        # Have one founder with a slack_user_id.
        startup.founders.first.update!(slack_user_id: 'xxxxxx')

        # Create two other expired startups, outside pruning region.
        recent_expiry = create :payment, :paid, billing_end_at: 3.days.ago
        not_recent_expiry = create :payment, :paid, billing_end_at: 5.days.ago

        # These team leads should not be processed.
        recent_expiry.startup.team_lead.update!(slack_user_id: rand(1_000_000))
        not_recent_expiry.startup.team_lead.update!(slack_user_id: rand(1_000_000))
      end

      it 'requests her Slack removal, emails her about it and announces it on the channels' do
        expect(PublicSlack::ApiService).to receive(:new).and_return(mock_api_service)
        expect(mock_api_service).to receive(:get).with('groups.list').and_return(group_ids)

        # Expect a successful pruning.
        expect(mock_api_service).to receive(:get)
          .with('groups.kick', params: { channel: 'group_id_1', user: 'xxxxxx' }).and_return(ok_response)

        # Expect a not_in_group exception to be silently ignored.
        expect(mock_api_service).to receive(:get)
          .with('groups.kick', params: { channel: 'group_id_2', user: 'xxxxxx' }).and_raise(not_in_group_exception)

        # Expect notifications to have been sent to both the channels.
        expect(PublicSlack::MessageService).to receive(:new).twice.and_return(mock_message_service)
        message = I18n.t('services.public_slack.prune_membership.removal_notice')
        expect(mock_message_service).to receive(:post).with(message: message, channel: 'group_id_1')
        expect(mock_message_service).to receive(:post).with(message: message, channel: 'group_id_2')

        subject.execute

        # The founder must have received an email about the removal.
        open_email(startup.founders.first.email)
        expect(current_email.subject).to include('Your SV.CO Slack membership has been revoked!')
      end
    end
  end
end
