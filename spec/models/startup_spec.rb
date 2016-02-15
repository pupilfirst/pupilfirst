require 'rails_helper'

describe Startup, broken: true do
  subject { create :startup }

  context 'when startup is destroyed' do
    let(:startup) { create :startup }

    it 'clears association from founders' do
      founder = create :founder_with_out_password, startup: startup
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

  it "should have atleast one founder" do
    startup = create(:startup)
    startup.founders = []
    expect(startup.valid?).to eql(false)
    expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe '.student_startups' do
    it "should return only students startups" do
      create :startup
      startup_2 = create :startup
      university = create :university

      student_founder = create :founder_with_out_password, university: university, roll_number: rand(10_000).to_s
      startup_2.founders << student_founder

      expect(Startup.student_startups).to eq([startup_2])
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

  describe '#phone' do
    it "returns startup admin's phone number" do
      expect(subject.phone).to eq subject.admin.phone
    end
  end

  describe '#showcase_timeline_event' do
    it 'returns last non-private verified timeline event with image' do
      private_timeline_event_type = create :timeline_event_type, private: true

      # Verified event with image.
      expected_showcase_event = create :timeline_event_with_image, startup: subject, verified_at: 20.minutes.ago

      # Verified event without image.
      create :timeline_event, startup: subject, verified_at: 10.minutes.ago

      # Verified private event with image.
      create :timeline_event_with_image, timeline_event_type: private_timeline_event_type, startup: subject, verified_at: 5.minutes.ago

      # Unverified event with image, latest.
      create :timeline_event_with_image, startup: subject

      expect(subject.showcase_timeline_event).to eq(expected_showcase_event)
    end
  end
end
