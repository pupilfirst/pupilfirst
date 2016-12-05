require 'rails_helper'

RSpec.describe TargetGroup, type: :model do
  subject { described_class }

  context 'when a target group already exists' do
    let!(:target_group) { create :target_group }

    it 'raises error when attempting to create another with same number and program week' do
      expect do
        subject.create!(
          name: Faker::Lorem.word,
          description: Faker::Lorem.sentence,
          program_week: target_group.program_week,
          number: target_group.number
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
