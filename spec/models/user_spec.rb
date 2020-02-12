require 'rails_helper'

describe User, type: :model do
  context 'when a user already exists' do
    it 'blocks attempts to create user with different-case but same email' do
      user = create(:user, email: 'random@example.com')
      expect do
        User.create!(email: 'Random@example.com', school: user.school)
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

  describe '#image_or_avatar_url' do
    let!(:user) { create :user }
    context 'when the user has no uploaded image' do
      it 'returns a generated initials avatar' do
        expect(user.image_or_avatar_url).to match(%r{data:image\/svg\+xml;base64.+})
      end
    end

    context 'when the user has an uploaded image' do
      before do
        avatar = File.open(Rails.root.join('spec/support/uploads/faculty/donald_duck.jpg'))
        user.avatar.attach(io: avatar, filename: 'donald_duck.jpg')
        user.save!
      end

      it 'returns the image blob url' do
        expect(user.image_or_avatar_url).to match(%r{rails/active_storage/blobs\/.+\.jpg})
      end

      it 'returns the image representation when a variant is specified' do
        expect(user.image_or_avatar_url(variant: :thumb)).to match(%r{rails/active_storage/representations\/.+\.jpg})
      end
    end
  end
end
