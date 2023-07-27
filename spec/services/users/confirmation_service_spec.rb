require 'rails_helper'

describe Users::ConfirmationService do
  subject { described_class }

  let(:student) { create :student }
  let(:user) { student.user }

  context 'when user is signing in for the first time' do
    it 'sets confirmed_at for user' do
      expect { subject.new(user).execute }.to change {
        user.reload.confirmed_at
      }.from(nil)
    end
  end

  context 'when user is not signing in for the first time' do
    before { user.update!(confirmed_at: Time.zone.now) }

    it 'does not update confirmed_at' do
      expect { subject.new(user).execute }.to_not(
        change { user.reload.confirmed_at }
      )
    end
  end
end
