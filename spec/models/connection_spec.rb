require 'spec_helper'

describe Connection do
  before do
    # Let's disable User notifications for specs.
    UserPushNotifyJob.stub_chain(:new, :async, :perform)
  end

  context 'when a SV to User connection is created' do
    let(:performer) { double 'Notification Pusher' }
    let(:user) { create :user_with_out_password }
    let(:contact) { create :user_as_contact }

    it 'send notification to the user for whom connection is created' do
      UserPushNotifyJob.stub_chain(:new, async: performer)
      expect(performer).to receive(:perform).with(user.id, :create_connection, I18n.t('notifications.create_connection', fullname: contact.fullname),
        contact.attributes.slice('fullname', 'phone', 'email', 'company', 'designation'))

      create :connection, user: user, contact: contact, direction: Connection::DIRECTION_SV_TO_USER
    end
  end
end
