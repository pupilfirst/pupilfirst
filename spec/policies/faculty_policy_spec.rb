require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  permissions :connect? do
    let(:faculty_1) { create :faculty, school: startup.school }
    let(:faculty_2) { create :faculty, school: startup.school, connect_link: Faker::Internet.url }
    let!(:connect_slot) { create :connect_slot, faculty: faculty_1, slot_at: 6.days.from_now }
    let(:startup) { create :startup }
    let(:current_founder) { startup.founders.first }
    let!(:enrollment_1) { create :faculty_startup_enrollment, :with_course_enrollment, faculty: faculty_1, startup: startup }
    let!(:enrollment_2) { create :faculty_startup_enrollment, :with_course_enrollment, faculty: faculty_2, startup: startup }

    let(:pundit_user) do
      OpenStruct.new(
        current_user: current_founder&.user,
        current_founder: current_founder,
        current_school: current_founder&.school
      )
    end

    it 'grants access to founder when the faculty have available connect slots or connect link' do
      # faculty with connect slot
      expect(subject).to permit(pundit_user, faculty_1)
      # faculty with connect link
      expect(subject).to permit(pundit_user, faculty_2)
    end

    context 'when accessed by the public' do
      let(:current_founder) { nil }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, faculty_1)
      end
    end

    context 'when faculty does not have available connect slots or connect link' do
      let!(:connect_request) { create :connect_request, connect_slot: connect_slot }
      let(:faculty_2) { create :faculty, school: startup.school }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, faculty_1)
        expect(subject).not_to permit(pundit_user, faculty_2)
      end
    end

    context "when the faculty is not enrolled to review the teams's submissions" do
      let!(:enrollment_1) { nil }
      let!(:enrollment_2) { nil }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, faculty_1)
        expect(subject).not_to permit(pundit_user, faculty_2)
      end
    end
  end
end
