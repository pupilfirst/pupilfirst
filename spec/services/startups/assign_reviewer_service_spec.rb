require 'rails_helper'

describe Startups::AssignReviewerService do
  subject { described_class.new(team) }

  let(:team) { create :team }
  let(:coach) { create :faculty }

  before do
    create :faculty_course_enrollment, faculty: coach, course: team.course
  end

  describe '#assign' do
    it 'links coach to the team' do
      expect { subject.assign([coach.id]) }.to(change { FacultyStartupEnrollment.count }.from(0).to(1))

      team_enrollment = FacultyStartupEnrollment.first

      expect(team_enrollment.faculty).to eq(coach)
      expect(team_enrollment.startup).to eq(team)
    end

    context "if a coach isn't assigned to the course" do
      let(:another_team) { create :team }
      let(:another_coach) { create :faculty }

      before do
        create :faculty_course_enrollment, faculty: another_coach, course: another_team.course
      end

      it 'raises exception' do
        expect { subject.assign([coach.id, another_coach.id]) }.to(
          raise_exception("All coaches must be assigned to the team's course")
        )
      end
    end

    context 'if the enrollment already exists' do
      before do
        create :faculty_startup_enrollment, faculty: coach, startup: team
      end

      it 'does nothing' do
        expect { subject.assign([coach.id]) }.not_to(change { FacultyStartupEnrollment.count })
      end
    end
  end
end
