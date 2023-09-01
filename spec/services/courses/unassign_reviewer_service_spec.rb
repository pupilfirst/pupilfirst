require "rails_helper"

describe Cohorts::UnassignReviewerService do
  subject { described_class.new(course) }

  let(:course) { create :course }
  let(:cohort) { create :cohort, course: course }
  let(:faculty) { create :faculty }
  let(:another_faculty) { create :faculty }

  describe "#unassign" do
    context "when the faculty is assigned to the course" do
      before do
        create :faculty_cohort_enrollment, faculty: faculty, cohort: cohort
        create :faculty_cohort_enrollment,
               faculty: another_faculty,
               cohort: cohort
      end

      it "removes the faculty enrollment from the course" do
        expect { subject.unassign(faculty) }.to(
          change { FacultyCohortEnrollment.count }.from(2).to(1)
        )

        # Only the entry for the other faculty member should remain.
        expect(FacultyCohortEnrollment.first.faculty).to eq(another_faculty)
      end
    end

    context "when the faculty is assigned to a few teams in the course" do
      let(:level_1) { create :level, :one, course: course }
      let(:level_2) { create :level, :two, course: course }
      let(:student_l1) { create :student, cohort: cohort }
      let(:student_l2_1) { create :student, cohort: cohort }
      let(:student_l2_2) { create :student, cohort: cohort }

      before do
        create :faculty_student_enrollment,
               :with_cohort_enrollment,
               faculty: faculty,
               student: student_l1
        create :faculty_student_enrollment,
               :with_cohort_enrollment,
               faculty: faculty,
               student: student_l2_1
        create :faculty_student_enrollment,
               :with_cohort_enrollment,
               faculty: another_faculty,
               student: student_l2_2
      end

      it "removes faculty enrollment from all teams in the course" do
        expect { subject.unassign(faculty) }.to(
          change { FacultyStudentEnrollment.count }.from(3).to(1)
        )

        # Only the entry for the other faculty member should remain.
        expect(FacultyStudentEnrollment.first.faculty).to eq(another_faculty)
      end
    end
  end
end
