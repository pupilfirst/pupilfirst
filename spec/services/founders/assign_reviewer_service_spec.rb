require 'rails_helper'

describe Students::AssignReviewerService do
  subject { described_class.new(student) }

  let(:cohort) { create :cohort }
  let(:student) { create :student, cohort: cohort }
  let(:coach) { create :faculty }

  before { create :faculty_cohort_enrollment, faculty: coach, cohort: cohort }

  describe '#assign' do
    it 'links coach to the student' do
      expect { subject.assign([coach.id]) }.to(
        change { FacultyStudentEnrollment.count }.from(0).to(1)
      )

      student_enrollment = FacultyStudentEnrollment.first

      expect(student_enrollment.faculty).to eq(coach)
      expect(student_enrollment.student).to eq(student)
    end

    context "if a coach isn't assigned to the course" do
      let(:another_cohort) { create :cohort }
      let(:another_student) { create :student, cohort: cohort }
      let(:another_coach) { create :faculty }

      before do
        create :faculty_cohort_enrollment,
               faculty: another_coach,
               cohort: another_cohort
      end

      it 'raises exception' do
        expect { subject.assign([coach.id, another_coach.id]) }.to(
          raise_exception(
            "All coaches must be assigned to the student's course"
          )
        )
      end
    end

    context 'if the enrollment already exists' do
      before do
        create :faculty_student_enrollment, faculty: coach, student: student
      end

      it 'does nothing' do
        expect { subject.assign([coach.id]) }.not_to(
          change { FacultyStudentEnrollment.count }
        )
      end
    end
  end
end
