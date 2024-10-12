require 'rails_helper'

RSpec.describe DiscordRole, type: :model do
  describe '#destroy' do
    it 'removes additional_user_discord_roles' do
      count = AdditionalUserDiscordRole.count

      user = create(:user)
      role = user.school.discord_roles.create discord_id: 'test_discord_id'
      user.discord_roles << role
      expect(AdditionalUserDiscordRole.count).to eq(count + 1)

      role.destroy
      expect(AdditionalUserDiscordRole.count).to eq(count)
    end
  end
end
