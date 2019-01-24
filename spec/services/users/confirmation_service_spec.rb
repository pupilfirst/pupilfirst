require 'rails_helper'

describe Users::ConfirmationService do
  subject { described_class }

  let(:startup) { create :startup }
  let(:founder) { startup.founders.first }
  let(:user) { founder.user }

  context 'when user is signing in for the first time' do
    it 'sets confirmed_at for user' do
      expect do
        subject.new(user).execute
      end.to change { user.reload.confirmed_at }.from(nil)
    end
  end

  context 'when user is not signing in for the first time' do
    before do
      user.update!(confirmed_at: Time.zone.now)
    end

    it 'does not update confirmed_at' do
      expect do
        subject.new(user).execute
      end.to_not(change { user.reload.confirmed_at })
    end
  end
end
