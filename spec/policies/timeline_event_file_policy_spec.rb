require "rails_helper"

describe TimelineEventFilePolicy do
  subject { described_class }

  permissions(:download?) do
    let(:team) { create :team_with_students }
    let(:another_team) { create :team_with_students, cohort: team.cohort }

    let(:course_faculty) { create :faculty, school: team.school }
    let(:student_faculty) { create :faculty, school: team.school }

    let(:level_1) { create :level, :one, course: team.course }

    let(:target_group) { create :target_group, level: level_1 }
    let(:target) { create :target, target_group: target_group }
    let(:timeline_event) do
      create :timeline_event, target: target, students: team.students
    end
    let(:timeline_event_file) do
      create :timeline_event_file, timeline_event: timeline_event
    end

    let!(:course_enrollment) do
      create :faculty_cohort_enrollment,
             faculty: course_faculty,
             cohort: team.cohort
    end
    let!(:student_enrollment) do
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: student_faculty,
             student: team.students.first
    end

    context "when the current user is a course coach for the linked course" do
      let(:pundit_user) do
        OpenStruct.new(
          current_user: course_faculty.user,
          current_coach: course_faculty
        )
      end

      it "grants access" do
        expect(subject).to permit(pundit_user, timeline_event_file)
      end
    end

    context "when the current user is a student coach for the linked student" do
      let(:pundit_user) do
        OpenStruct.new(
          current_user: student_faculty.user,
          current_coach: student_faculty
        )
      end

      it "grants access" do
        expect(subject).to permit(pundit_user, timeline_event_file)
      end
    end

    context "when the current user is one of the students linked to the timeline event" do
      let(:pundit_user) do
        OpenStruct.new(current_user: team.students.first.user)
      end

      it "grants access" do
        expect(subject).to permit(pundit_user, timeline_event_file)
      end
    end

    context "for any other user" do
      let(:pundit_user) do
        OpenStruct.new(current_user: another_team.students.first.user)
      end

      it "denies access" do
        expect(subject).not_to permit(pundit_user, timeline_event_file)
      end

      context "when there is no linked submission" do
        let(:timeline_event_file) do
          create :timeline_event_file, timeline_event: nil
        end

        it "grants access" do
          expect(subject).to permit(pundit_user, timeline_event_file)
        end
      end
    end
  end
end
