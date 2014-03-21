require 'spec_helper'

describe Startup do

	it "should have atleast one founder" do
		startup = create(:startup)
		startup.founders = []
		expect(startup.valid?).to eql(false)
		expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
	end

	it "returns only verified users as founders" do
		startup = create(:startup)
		founder = startup.founders.last
		founder_count = startup.founders.count
		founder.update_attributes!(startup_link_verifier_id: nil, startup_verifier_token: nil)
		expect(startup.reload.founders.count).to eql(founder_count - 1)
	end

	it "validates the size of pitch" do
		startup = build(:startup, pitch: Faker::Lorem.words(200).join(' '))
		expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
	end

	it "validates the size of about" do
		startup = build(:startup, about: Faker::Lorem.words(513, true).join(' '))
		expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
		startup.about = Faker::Lorem.words(5).join(' ')
		expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
	end

	it "validates the presence of reqired params" do
		startup = build(:startup)
		expect { startup.update_attributes!(name: nil) }.to raise_error(ActiveRecord::RecordInvalid)
		expect { startup.update_attributes!(logo: nil) }.to raise_error(ActiveRecord::RecordInvalid)
		expect { startup.update_attributes!(phone: nil) }.to raise_error(ActiveRecord::RecordInvalid)
		expect { startup.update_attributes!(email: nil) }.to raise_error(ActiveRecord::RecordInvalid)
		expect { startup.update_attributes!(categories: []) }.to raise_error(ActiveRecord::RecordInvalid)
	end

	context 'normalize twitter_link' do
		it "to link if username is given" do
			startup = create(:startup, twitter_link: "gouthamvel")
			expect( startup.twitter_link).to eq("http://twitter.com/gouthamvel")
		end

		it "to link with http if link starts with twitter.com" do
			startup = create(:startup, twitter_link: "twitter.com/gouthamvel")
			expect( startup.twitter_link).to eq("http://twitter.com/gouthamvel")
		end

		it "remains unchanged if the url is valid" do
			startup = create(:startup, twitter_link: "http://twitter.com/gouthamvel")
			expect( startup.twitter_link).to eq("http://twitter.com/gouthamvel")
		end
	end

	context 'normalize facebook_link' do
		it "to link if username is given" do
			startup = create(:startup, facebook_link: "gouthamvel")
			expect( startup.facebook_link).to eq("http://facebook.com/gouthamvel")
		end

		it "to link with http if link starts with twitter.com" do
			startup = create(:startup, facebook_link: "facebook.com/gouthamvel")
			expect( startup.facebook_link).to eq("http://facebook.com/gouthamvel")
		end

		it "remains unchanged if the url is valid" do
			startup = create(:startup, facebook_link: "http://facebook.com/gouthamvel")
			expect( startup.facebook_link).to eq("http://facebook.com/gouthamvel")
		end
	end
end
