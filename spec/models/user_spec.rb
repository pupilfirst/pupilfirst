require 'spec_helper'

describe User do
	context 'normalize twitter_url' do
		it "to link if username is given" do
			user = create(:user, twitter_url: "gouthamvel")
			expect( user.twitter_url).to eq("http://twitter.com/gouthamvel")
		end

		it "to link with http if link starts with twitter.com" do
			user = create(:user, twitter_url: "twitter.com/gouthamvel")
			expect( user.twitter_url).to eq("http://twitter.com/gouthamvel")
		end

		it "remains unchanged if the url is valid" do
			user = create(:user, twitter_url: "http://twitter.com/gouthamvel")
			expect( user.twitter_url).to eq("http://twitter.com/gouthamvel")
		end
	end

	context 'normalize linkedin_url' do
		it "to link if username is given" do
			user = create(:user, linkedin_url: "gouthamvel")
			expect( user.linkedin_url).to eq("http://linkedin.com/in/gouthamvel")
		end

		it "to link with http if link starts with twitter.com" do
			user = create(:user, linkedin_url: "linkedin.com/in/gouthamvel")
			expect( user.linkedin_url).to eq("http://linkedin.com/in/gouthamvel")
		end

		it "remains unchanged if the url is valid" do
			user = create(:user, linkedin_url: "http://linkedin.com/in/gouthamvel")
			expect( user.linkedin_url).to eq("http://linkedin.com/in/gouthamvel")
		end
	end
end
