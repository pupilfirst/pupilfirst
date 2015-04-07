require 'rails_helper'

describe User do
  context 'non_founders scopes' do
    it 'returns users who are not related to any startup' do
      user = create(:user_with_out_password, startup: nil)
      expect(User.non_founders.map &:id).to include(user.id)
    end
  end

  describe '#remove_from_startup!' do
    it 'disassociates a user from startup completely' do
      startup = create :startup
      founder = startup.founders.first
      founder.remove_from_startup!
      founder.reload
      expect(founder.startup).to eq nil
      expect(founder.is_founder).to eq nil
      expect(founder.startup_admin).to eq nil
    end
  end
end
