require 'rails_helper'

describe User, type: :model do
  context 'when a user already exists' do
    it 'blocks attempts to create user with different-case but same email' do
      create(:user, email: 'random@example.com')
      expect do
        User.create!(email: 'Random@example.com')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#with_email' do
    it 'performs case-insensitive search by email' do
      user = create(:user, email: 'random@example.com')
      fetched_user = User.with_email('Random@example.com').first
      expect(fetched_user).to eq(user)
    end
  end
end
