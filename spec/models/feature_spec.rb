require 'rails_helper'

RSpec.describe Feature, type: :model do
  before :all do
    Feature.skip_override = true
  end

  after :all do
    Feature.skip_override = false
  end

  describe '.active?' do
    def user(email)
      OpenStruct.new(email: email)
    end

    context 'when a feature is not configured' do
      it 'returns false' do
        expect(Feature.active?(:non_existent_feature, user('someone@sv.co'))).to eq(false)
      end
    end

    context 'with an admin feature' do
      before { create :feature, value: { admin: true }.to_json }

      it 'returns true for admin users' do
        admin_user = create(:admin_user)
        user = create(:user, email: admin_user.email)
        expect(Feature.active?(:test_feature, user)).to eq(true)
      end

      it 'returns false for non-admin users' do
        user = create(:user)
        expect(Feature.active?(:test_feature, user)).to eq(false)
      end

      it 'returns false for the public' do
        expect(Feature.active?(:test_feature)).to eq(false)
      end
    end

    context 'with a regex feature' do
      before { create :feature, value: { email_regexes: %w[\S+@sv.co$ \S+@mobme.in$] }.to_json }

      it 'returns true for emails that match regex' do
        expect(Feature.active?(:test_feature, user('someone@sv.co'))).to eq(true)
        expect(Feature.active?(:test_feature, user('someone_else@mobme.in'))).to eq(true)
      end

      it 'returns false for emails that do not match regex' do
        expect(Feature.active?(:test_feature, user('someone@sv.com'))).to eq(false)
        expect(Feature.active?(:test_feature, user('mobme.in'))).to eq(false)
      end
    end

    context 'with a email-list based feature' do
      before { create :feature, value: { emails: %w[someone@sv.co someone@mobme.in] }.to_json }

      it 'returns true for emails that are in the list' do
        expect(Feature.active?(:test_feature, user('someone@sv.co'))).to eq(true)
        expect(Feature.active?(:test_feature, user('someone@mobme.in'))).to eq(true)
      end

      it 'returns false for emails not in the list' do
        expect(Feature.active?(:test_feature, user('someone_else@sv.co'))).to eq(false)
      end
    end

    context 'with an activated feature' do
      before { create :feature, value: { active: true }.to_json }

      it 'returns true for everyone' do
        expect(Feature.active?(:test_feature, user('someone@sv.co'))).to eq(true)
        expect(Feature.active?(:test_feature, user('foo@example.com'))).to eq(true)
      end
    end
  end
end
