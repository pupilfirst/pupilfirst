require 'spec_helper'

describe Startup do
	it "validates the size of pitch" do
		startup = build(:startup, pitch: Faker::Lorem.words(20).join(' '))
		expect { startup.save! }.to raise_error(ActiveRecord::RecordInvalid)
		startup.pitch = Faker::Lorem.words(1).join(' ')
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

end
