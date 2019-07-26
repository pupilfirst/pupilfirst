require 'rails_helper'

describe Courses::AssignReviewerService do
  subject { described_class.new(course) }

  let(:course) { create :course }
  let(:faculty) { create :faculty }

  describe '#assign' do
    context 'if the faculty is in a different school' do
      let(:new_school) { create :school }
      let(:faculty_user_in_new_school) { create :user, school_id: new_school.id }
      let(:faculty) { create :faculty, user: faculty_user_in_new_school }

      it 'raises exception' do
        expect { subject.assign(faculty) }.to raise_exception('Faculty must in same school as course')
      end
    end

    context 'if the course is already assigned' do
      before do
        create :faculty_course_enrollment, faculty: faculty, course: course
      end

      it 'does nothing' do
        expect { subject.assign(faculty) }.not_to(change { FacultyCourseEnrollment.count })
      end
    end

    context 'if the course is not already assigned' do
      it 'assigns the faculty to the course' do
        expect { subject.assign(faculty) }.to(change { FacultyCourseEnrollment.count }.from(0).to(1))

        enrollment = FacultyCourseEnrollment.first

        expect(enrollment.faculty).to eq(faculty)
        expect(enrollment.course).to eq(course)
      end

      context 'if the faculty is assigned to a few startups in the course' do
        let(:level_1) { create :level, :one, course: course }
        let(:level_2) { create :level, :two, course: course }
        let(:startup_l1) { create :startup, level: level_1 }
        let(:startup_l2) { create :startup, level: level_2 }

        before do
          create :faculty_startup_enrollment, faculty: faculty, startup: startup_l1
          create :faculty_startup_enrollment, faculty: faculty, startup: startup_l2
        end

        it 'removes direct linking to startups in course' do
          expect { subject.assign(faculty) }.to(change { FacultyStartupEnrollment.count }.from(2).to(0))
        end
      end
    end
  end
end
