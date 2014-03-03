require 'spec_helper'

describe User do
	context 'normalize twitter_url' do
		it "to link if username is given" do
			user = create(:user_with_out_password, twitter_url: "gouthamvel")
			expect( user.twitter_url).to eq("http://twitter.com/gouthamvel")
		end

		it "to link with http if link starts with twitter.com" do
			user = create(:user_with_out_password, twitter_url: "twitter.com/gouthamvel")
			expect( user.twitter_url).to eq("http://twitter.com/gouthamvel")
		end

		it "remains unchanged if the url is valid" do
			user = create(:user_with_out_password, twitter_url: "http://twitter.com/gouthamvel")
			expect( user.twitter_url).to eq("http://twitter.com/gouthamvel")
		end
	end

	context 'normalize linkedin_url' do
		it "to link if username is given" do
			user = create(:user_with_out_password, linkedin_url: "gouthamvel")
			expect( user.linkedin_url).to eq("http://linkedin.com/in/gouthamvel")
		end

		it "to link with http if link starts with twitter.com" do
			user = create(:user_with_out_password, linkedin_url: "linkedin.com/in/gouthamvel")
			expect( user.linkedin_url).to eq("http://linkedin.com/in/gouthamvel")
		end

		it "remains unchanged if the url is valid" do
			user = create(:user_with_out_password, linkedin_url: "http://linkedin.com/in/gouthamvel")
			expect( user.linkedin_url).to eq("http://linkedin.com/in/gouthamvel")
		end
	end

	context "non_founders scopes" do
		it "returns users who are not related to any startup" do
			user = create(:user_with_out_password, startup: nil)
			expect(User.non_founders.map &:id).to include(user.id)
		end
	end

	context "verify user as founder" do
		before(:all) do
			@startup = create(:startup)
			@startup2 = create(:startup)
			@user = create(:user_with_out_password, startup: @startup)
			@user_self = create(:user_with_out_password, startup: @startup, startup_link_verifier: @user)
			@user_other = create(:user_with_out_password, startup: @startup, startup_link_verifier: nil)
		end

		it "if self is verified and belongs to same startup" do
			@user_self.startup =  @startup
			@user_self.startup_link_verifier =  @user
			@user_other.startup =  @startup
			@user_other.startup_link_verifier =  false
			expect(@user_self.verify(@user_other)).to be_truthy
			expect(@user_other.startup_link_verifier).to eql(@user_self)
			expect(@user_other.startup_verifier_token).not_to eql(nil)
			expect(@user_other.startup_verifier_token).not_to eql("")
		end

		it "raises exception if self is not verfiied" do
			@user_self.update_attributes!(startup_link_verifier: nil)
			expect{@user_self.verify(@user_other)}.to raise_exception(/not allowed to verify founders yet/)
		end

		it "raises exception if both user doesn't belongs to same startup" do
			@user_self.update_attributes!(startup_link_verifier: @user, startup: nil)
			expect{@user_self.verify(@user_other)}.to raise_exception(/not allowed to verify founders of/)
			@user_self.update_attributes!(startup_link_verifier: @user, startup: @startup2)
			expect{@user_self.verify(@user_other)}.to raise_exception(/not allowed to verify founders of/)
		end
	end
end
