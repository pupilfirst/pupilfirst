require 'rails_helper'

RSpec.describe Target, type: :model do
  subject { create :target }

  context 'when trying to archive a target' do
    context 'if safe_to_change_visibility is not set' do
      it 'fails validation' do
        subject.update(visibility: Target::VISIBILITY_ARCHIVED)
        expect(subject.errors.to_a).to include('Visibility cannot be modified unsafely')
        expect(subject.reload.visibility).to eq(Target::VISIBILITY_LIVE)
      end
    end

    context 'if safe_to_change_visibility is set' do
      it 'passes validation' do
        subject.update!(visibility: Target::VISIBILITY_ARCHIVED, safe_to_change_visibility: true)
        expect(subject.reload.visibility).to eq(Target::VISIBILITY_ARCHIVED)
      end
    end
  end

  context 'when trying to unarchive a target' do
    subject { create :target, :archived }

    it 'unarchives target regardless of safe_to_change_visibility' do
      subject.update!(visibility: Target::VISIBILITY_LIVE)
      expect(subject.reload.visibility).to eq(Target::VISIBILITY_LIVE)
    end
  end
end
