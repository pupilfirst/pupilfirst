require 'rails_helper'

describe Courses::UnassignReviewerService do
  subject { described_class.new(course) }

  let(:course) { create :course }
  let(:faculty) { create :faculty }
  let(:another_faculty) { create :faculty }

  describe '#unassign' do
    context 'when the faculty is assigned to the course' do
      before do
        create :faculty_course_enrollment, faculty: faculty, course: course
        create :faculty_course_enrollment, faculty: another_faculty, course: course
      end

      it 'removes the faculty enrollment from the course' do
        expect { subject.unassign(faculty) }.to(change { FacultyCourseEnrollment.count }.from(2).to(1))

        # Only the entry for the other faculty member should remain.
        expect(FacultyCourseEnrollment.first.faculty).to eq(another_faculty)
      end
    end

    context 'when the faculty is assigned to a few teams in the course' do
      let(:level_1) { create :level, :one, course: course }
      let(:level_2) { create :level, :two, course: course }
      let(:startup_l1) { create :startup, level: level_1 }
      let(:startup_l2_1) { create :startup, level: level_2 }
      let(:startup_l2_2) { create :startup, level: level_2 }

      before do
        create :faculty_startup_enrollment, :with_course_enrollment, faculty: faculty, startup: startup_l1
        create :faculty_startup_enrollment, :with_course_enrollment, faculty: faculty, startup: startup_l2_1
        create :faculty_startup_enrollment, :with_course_enrollment, faculty: another_faculty, startup: startup_l2_2
      end

      it 'removes faculty enrollment from all teams in the course' do
        expect { subject.unassign(faculty) }.to(change { FacultyStartupEnrollment.count }.from(3).to(1))

        # Only the entry for the other faculty member should remain.
        expect(FacultyStartupEnrollment.first.faculty).to eq(another_faculty)
      end
    end
  end
end
