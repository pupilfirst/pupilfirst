require 'rails_helper'

describe Startup do
  subject { create :startup }

  context 'when attempting to destroy a startup' do
    let(:startup) { create :startup }

    it 'cannot be destroyed if it has founders' do
      create :founder, startup: startup

      expect do
        startup.destroy!
      end.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  it "validates the size of pitch" do
    startup = build(:startup, pitch: Faker::Lorem.words(200).join(' '))
    expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'normalize twitter_link' do
    it "to link if username is empty/nil" do
      startup = create(:startup, twitter_link: "")
      expect(startup.twitter_link).to eq(nil)
      startup = create(:startup, twitter_link: nil)
      expect(startup.twitter_link).to eq(nil)
    end

    it "to link if username is given" do
      startup = create(:startup, twitter_link: "gouthamvel")
      expect(startup.twitter_link).to eq('https://twitter.com/gouthamvel')
    end

    it "to link with http if link starts with twitter.com" do
      startup = create(:startup, twitter_link: "twitter.com/gouthamvel")
      expect(startup.twitter_link).to eq('https://twitter.com/gouthamvel')
    end

    it "remains unchanged if the url is valid" do
      startup = create(:startup, twitter_link: "http://twitter.com/gouthamvel")
      expect(startup.twitter_link).to eq("http://twitter.com/gouthamvel")
    end
  end

  context 'normalize facebook_link' do
    it "to link if username is empty/nil" do
      startup = create(:startup, facebook_link: "")
      expect(startup.facebook_link).to eq(nil)
      startup = create(:startup, facebook_link: nil)
      expect(startup.facebook_link).to eq(nil)
    end

    it "to link if username is given" do
      startup = create(:startup, facebook_link: "gouthamvel")
      expect(startup.facebook_link).to eq('https://facebook.com/gouthamvel')
    end

    it "to link with http if link starts with twitter.com" do
      startup = create(:startup, facebook_link: "facebook.com/gouthamvel")
      expect(startup.facebook_link).to eq('https://facebook.com/gouthamvel')
    end

    it "remains unchanged if the url is valid" do
      startup = create(:startup, facebook_link: "http://facebook.com/gouthamvel")
      expect(startup.facebook_link).to eq("http://facebook.com/gouthamvel")
    end
  end
end
