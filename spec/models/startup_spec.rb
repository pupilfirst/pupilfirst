require 'spec_helper'

describe Startup do
  context 'when startup is destroyed' do
    let(:startup) { create :startup }

    it 'clears association from users' do
      user = create :user_with_out_password, startup: startup
      startup.destroy!
      user.reload
      expect(user.startup_id).to eq nil
    end

    it 'clears association from pending users' do
      user = create :user_with_out_password, pending_startup_id: startup.id
      startup.destroy!
      user.reload
      expect(user.pending_startup_id).to eq nil
    end
  end

  it "can't have more than 3 categories" do
    startup = build(:startup)
    category_1 = create(:startup_category)
    category_2 = create(:startup_category)
    category_3 = create(:startup_category)
    category_4 = create(:startup_category)
    startup.categories = "#{category_1.id},#{category_2.id},#{category_3.id},#{category_4.id}"

    expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should have atleast one founder" do
    startup = create(:startup)
    startup.founders = []
    expect(startup.valid?).to eql(false)
    expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "validates the size of pitch" do
    startup = build(:startup, pitch: Faker::Lorem.words(200).join(' '))
    expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'validates the size of about' do
    startup = build(:startup, about: Faker::Lorem.characters(1003))
    expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  # it "validates the presence of reqired params" do
  #   startup = build(:startup)
  #   expect { startup.update_attributes!(name: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  #   expect { startup.update_attributes!(logo: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  #   expect { startup.update_attributes!(phone: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  #   expect { startup.update_attributes!(email: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  #   expect { startup.update_attributes!(categories: []) }.to raise_error(ActiveRecord::RecordInvalid)
  # end

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
