require 'rails_helper'

describe Cohorts::ManageReviewerService do
  subject { described_class.new(course, [cohort_1, cohort_2]) }

  let(:course) { create :course }
  let(:cohort_1) { create :cohort, course: course }
  let(:cohort_2) { create :cohort, course: course }
  let(:faculty) { create :faculty }

  describe '#assign' do
    it 'assigns the faculty to the course' do
      expect { subject.assign(faculty) }.to(
        change { FacultyCohortEnrollment.count }.from(0).to(2)
      )

      enrollment = FacultyCohortEnrollment.first
      expect(enrollment.faculty).to eq(faculty)
      expect(enrollment.cohort).to eq(cohort_1)
    end

    context 'if the cohort is already assigned' do
      before do
        create :faculty_cohort_enrollment, faculty: faculty, cohort: cohort_1
      end

      it 'does not duplicate enrollement' do
        expect { subject.assign(faculty) }.to(
          change { FacultyCohortEnrollment.count }.from(1).to(2)
        )
      end
    end

    context 'if the faculty is in a different school' do
      let(:new_school) { create :school }
      let(:faculty_user_in_new_school) do
        create :user, school_id: new_school.id
      end
      let(:faculty) { create :faculty, user: faculty_user_in_new_school }

      it 'raises exception' do
        expect { subject.assign(faculty) }.to raise_exception(
          'Faculty must in same school as course'
        )
      end
    end
  end
end
