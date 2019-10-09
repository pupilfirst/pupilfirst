require 'rails_helper'

describe MarkdownAttachmentPolicy do
  subject { described_class }

  let(:school) { create :school, :current }
  let(:markdown_attachment) { create :markdown_attachment, user: user }
  let(:user) { create :user, school: school }

  let(:pundit_user) do
    OpenStruct.new(
      current_school: school
    )
  end

  permissions :download? do
    it 'grants access' do
      expect(subject).to permit(pundit_user, markdown_attachment)
    end

    context 'when the attachment was created by a user in another school' do
      let(:another_school) { create :school }
      let(:user) { create :user, school: another_school }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, markdown_attachment)
      end
    end
  end
end
