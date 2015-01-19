require 'spec_helper'

describe StartupJob do
  subject { create :startup_job }

  describe '#can_be_modified_by?' do
    context 'when user is nil' do
      it 'returns false' do
        expect(subject.can_be_modified_by? nil).to eq(false)
      end
    end

    context "when user is founder at job's startup" do
      it 'returns true' do
        user = subject.startup.founders.first
        expect(subject.can_be_modified_by?(user)).to eq(true)
      end
    end

    context "when user is not founder at job's startup" do
      it 'returns false' do
        user = create :user_with_out_password
        expect(subject.can_be_modified_by?(user)).to eq(false)
      end
    end
  end

  describe '#expired?' do
    context "when job is expired" do
      subject { create :startup_job, expires_on: StartupJob::EXPIRY_DURATION.ago  }

      it 'returns true' do
        expect(subject.expired?).to eq(true)
      end
    end

    context 'when job is not expired' do
      subject { create :startup_job, expires_on: StartupJob::EXPIRY_DURATION.since }

      it 'returns false' do
        expect(subject.expired?).to eq(false)
      end
    end
  end

  describe '#reset_expiry!' do
    context "when resets the job's expiry date" do
      subject { create :startup_job, expires_on: StartupJob::EXPIRY_DURATION.ago }

      it 'resets expiry date' do
        subject.reset_expiry!
        expect(subject.expired?).to eq(false)
      end
    end
  end

  describe '#equity_min_less_than_max' do
    context "when equity min greater than max" do
      subject { build :startup_job, equity_max: 100, equity_min: 1000, equity_vest: 4, equity_cliff:1 }

      it 'invalidates record' do
        expect(subject).to_not be_valid
      end
    end
  end
end
