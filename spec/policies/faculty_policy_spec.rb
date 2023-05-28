require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  permissions :connect? do
    let(:coach_1) { create :faculty }
    let(:coach_2) { create :faculty, connect_link: Faker::Internet.url }
    let(:current_student) { create :student }
    let(:current_coach) { nil }
    let(:current_school_admin) { nil }

    let(:pundit_user) do
      OpenStruct.new(
        current_user: current_student&.user,
        current_student: current_student,
        current_school: current_student&.school,
        current_coach: current_coach,
        current_school_admin: current_school_admin
      )
    end

    context 'when the coaches are enrolled in a students course' do
      let!(:enrollment_1) do
        create :faculty_student_enrollment,
               :with_cohort_enrollment,
               faculty: coach_1,
               student: current_student
      end
      let!(:enrollment_2) do
        create :faculty_student_enrollment,
               :with_cohort_enrollment,
               faculty: coach_2,
               student: current_student
      end

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
      let(:current_student) { nil }

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
      let(:current_school_admin) do
        create :school_admin,
               school: current_student.school,
               user: current_student.user
      end

      it 'grants access even without coach enrollment' do
        # coach without connect link
        expect(subject).not_to permit(pundit_user, coach_1)

        # coach with connect link
        expect(subject).to permit(pundit_user, coach_2)
      end
    end
  end
end
