require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  permissions :connect? do
    let(:coach_1) { create :faculty, school: startup.school }
    let(:coach_2) { create :faculty, school: startup.school, connect_link: Faker::Internet.url }
    let(:startup) { create :startup }
    let(:current_founder) { startup.founders.first }
    let(:current_coach) { nil }
    let(:current_school_admin) { nil }

    let(:pundit_user) do
      OpenStruct.new(
        current_user: current_founder&.user,
        current_founder: current_founder,
        current_school: current_founder&.school,
        current_coach: current_coach,
        current_school_admin: current_school_admin
      )
    end

    context 'when the coaches are enrolled in a students course' do
      let!(:enrollment_1) { create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_1, startup: startup }
      let!(:enrollment_2) { create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_2, startup: startup }

      it 'grants access to student when the coach has a connect link' do
        # coach without connect link
        expect(subject).not_to permit(pundit_user, coach_1)
        # coach with connect link
        expect(subject).to permit(pundit_user, coach_2)
      end
    end

    context "when the coaches are not enrolled in the student's course" do
      it 'denies access' do
        expect(subject).not_to permit(pundit_user, coach_1)
        expect(subject).not_to permit(pundit_user, coach_2)
      end
    end

    context 'when accessed by the public' do
      let(:current_founder) { nil }

      it 'denies access' do
        expect(subject).not_to permit(pundit_user, coach_1)
        expect(subject).not_to permit(pundit_user, coach_2)
      end
    end

    context 'when accessed by a coach' do
      let(:current_coach) { coach_1 }

      it 'grants access even without coach enrollment' do
        # coach without connect link
        expect(subject).not_to permit(pundit_user, coach_1)
        # coach with connect link
        expect(subject).to permit(pundit_user, coach_2)
      end
    end

    context 'when accessed by a school admin' do
      let(:current_school_admin) { create :school_admin, school: current_founder.school, user: current_founder.user }

      it 'grants access even without coach enrollment' do
        # coach without connect link
        expect(subject).not_to permit(pundit_user, coach_1)
        # coach with connect link
        expect(subject).to permit(pundit_user, coach_2)
      end
    end
  end
end
