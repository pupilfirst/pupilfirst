require 'rails_helper'

RSpec.describe TargetGroup, type: :model do
  subject { create :target_group }

  context 'when trying to archive a target group' do
    context 'if safe_to_archive is not set' do
      it 'fails validation' do
        subject.update(archived: true)
        expect(subject.errors.to_a).to include('Archived cannot be set unsafely')
        expect(subject.reload.archived?).to eq(false)
      end
    end

    context 'if safe_to_archive is set' do
      it 'passes validation' do
        subject.update!(archived: true, safe_to_archive: true)
        expect(subject.reload.archived?).to eq(true)
      end
    end
  end

  context 'when trying to unarchive a target' do
    subject { create :target_group, :archived }

    it 'unarchives target regardless of safe_to_archive' do
      subject.update!(archived: false)
      expect(subject.reload.archived?).to eq(false)
    end
  end
end
