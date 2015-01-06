require 'spec_helper'

describe User do
  context "non_founders scopes" do
    it "returns users who are not related to any startup" do
      user = create(:user_with_out_password, startup: nil)
      expect(User.non_founders.map &:id).to include(user.id)
    end
  end

  context "verify user as founder" do
    let(:startup)  { create(:startup)}
    let(:startup2)  { create(:startup)}
    let(:user)  { create(:user_with_out_password, startup: startup)}
    let(:user_self)  { create(:user_with_out_password, startup: startup, startup_link_verifier: user)}
    let(:user_other)  { create(:user_with_out_password, startup: startup, startup_link_verifier: nil)}

    it "if self is verified and belongs to same startup" do
      user_self.startup =  startup
      user_self.startup_link_verifier =  user
      user_other.startup =  startup
      user_other.startup_link_verifier =  false
      expect(user_self.verify(user_other)).to eq(true) # TODO: Make this be_truthy for Rspec v3.
      expect(user_other.startup_link_verifier).to eql(user_self)
      expect(user_other.startup_verifier_token).not_to eql(nil)
      expect(user_other.startup_verifier_token).not_to eql("")
    end

    it "raises exception if self is not verfiied" do
      user_self.update_attributes!(startup_link_verifier: nil)
      expect{user_self.verify(user_other)}.to raise_exception(/not allowed to verify founders yet/)
    end

    it "raises exception if both user doesn't belongs to same startup" do
      user_self.update_attributes!(startup_link_verifier: user, startup: nil)
      expect{user_self.verify(user_other)}.to raise_exception(/not allowed to verify founders of/)
      user_self.update_attributes!(startup_link_verifier: user, startup: startup2)
      expect{user_self.verify(user_other)}.to raise_exception(/not allowed to verify founders of/)
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
