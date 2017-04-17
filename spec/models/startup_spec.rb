require 'rails_helper'

describe Startup do
  subject { create :startup }

  context 'when startup is destroyed' do
    let(:startup) { create :startup }

    it 'clears association from founders' do
      founder = create :founder, startup: startup
      startup.destroy!
      founder.reload
      expect(founder.startup_id).to eq nil
    end
  end

  it "can't have more than 3 categories" do
    startup = build(:startup)
    category_2 = create(:startup_category)
    category_1 = create(:startup_category)
    category_3 = create(:startup_category)
    category_4 = create(:startup_category)
    startup.startup_categories = "#{category_1.id},#{category_2.id},#{category_3.id},#{category_4.id}"

    expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
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

  describe '#phone' do
    it "returns startup admin's phone number" do
      expect(subject.phone).to eq subject.admin.phone
    end
  end
end
