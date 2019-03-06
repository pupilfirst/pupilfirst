require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  permissions :connect? do
    let!(:connect_slot) { create :connect_slot, faculty: faculty, slot_at: 6.days.from_now }
    let(:startup) { create :startup }
    let(:faculty) { create :faculty, school: startup.school }
    let(:current_founder) { startup.founders.first }
    let!(:enrollment) { create :faculty_startup_enrollment, faculty: faculty, startup: startup }

    let(:pundit_user) do
      OpenStruct.new(
        current_user: current_founder&.user,
        current_founder: current_founder,
        current_school: current_founder&.school
      )
    end

    it 'grants access to founder' do
      expect(subject).to permit(pundit_user, faculty)
    end

    context 'when accessed by the public' do
      let(:current_founder) { nil }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, faculty)
      end
    end

    context 'when faculty does not have available connect slots or connect link' do
      let!(:connect_request) { create :connect_request, connect_slot: connect_slot }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, faculty)
      end
    end

    context "when the faculty is not enrolled to review the teams's submissions" do
      let!(:enrollment) { nil }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, faculty)
      end
    end
  end
end
