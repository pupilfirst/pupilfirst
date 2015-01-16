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
end
