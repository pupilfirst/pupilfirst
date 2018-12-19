require 'rails_helper'

describe Startups::AssignReviewerService do
  subject { described_class.new(startup) }

  let(:startup) { create :startup }
  let(:faculty) { create :faculty }

  describe '#assign' do
    context 'if the direct enrollment already exists' do
      before do
        create :faculty_startup_enrollment, faculty: faculty, startup: startup
      end

      it 'does nothing' do
        expect { subject.assign(faculty) }.not_to(change { FacultyStartupEnrollment.count })
      end
    end

    context 'if the direct enrollment does not exist' do
      context "'if the startup's course has enrolled the faculty" do
        before do
          create :faculty_course_enrollment, faculty: faculty, course: startup.level.course
        end

        it 'does nothing' do
          expect { subject.assign(faculty) }.not_to(change { FacultyStartupEnrollment.count })
        end
      end

      context "if the startup's course has not enrolled the faculty" do
        it 'links startup to faculty' do
          expect { subject.assign(faculty) }.to(change { FacultyStartupEnrollment.count }.from(0).to(1))

          enrollment = FacultyStartupEnrollment.first

          expect(enrollment.faculty).to eq(faculty)
          expect(enrollment.startup).to eq(startup)
        end
      end
    end
  end
end
