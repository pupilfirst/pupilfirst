require 'rails_helper'

describe PublicSlack::PruneMembershipService do
  subject { described_class.new }
  let!(:startup) { create :startup, :subscription_active }
  let(:mock_api_service) { instance_double PublicSlack::ApiService }
  let(:group_ids) { { 'groups' => [{ 'id' => 'group_id_1' }, { 'id' => 'group_id_2' }] } }
  let(:ok_response) { { 'ok' => true } }
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

    context 'when there is an expired founder to be pruned' do
      before do
        # Expire the startup subscription.
        startup.payments.last.update!(billing_start_at: 4.weeks.ago, billing_end_at: 4.days.ago)
        # Have one founder with a slack_user_id.
        startup.founders.first.update!(slack_user_id: 'xxxxxx')
      end

      it 'requests her Slack removal and emails her about it' do
        expect(PublicSlack::ApiService).to receive(:new).and_return(mock_api_service)
        expect(mock_api_service).to receive(:get).with('groups.list').and_return(group_ids)

        # Expect a successful pruning.
        expect(mock_api_service).to receive(:get)
          .with('groups.kick', params: { channel: 'group_id_1', user: 'xxxxxx' }).and_return(ok_response)

        # Expect a not_in_group exception to be silently ignored.
        expect(mock_api_service).to receive(:get)
          .with('groups.kick', params: { channel: 'group_id_2', user: 'xxxxxx' }).and_raise(not_in_group_exception)

        subject.execute

        # The founder must have received an email about the removal.
        open_email(startup.founders.first.email)
        expect(current_email.subject).to include('Your SV.CO Slack membership has been revoked!')
      end
    end
  end
end
