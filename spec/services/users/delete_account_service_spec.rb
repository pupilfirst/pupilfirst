require 'rails_helper'

describe Users::DeleteAccountService do
  subject { described_class.new(user) }

  # Setup the basics
  let(:user) { create :user }
  let!(:student) { create :student, user: user }
  let!(:student_team) { student.startup }
  let!(:student_with_teammates) { create :founder, user: user }
  let!(:team_with_user) { student_with_teammates.startup }
  let!(:coach) { create :faculty, user: user }
  let!(:course) { create :course, school: user.school }
  let!(:course_author) { create :course_author, user: user, course: course }

  # Coach notes for the founder profiles
  let!(:coach_note_1) { create :coach_note, student: student }

  # Create submissions by the student profile
  let(:course_1) { create :course, school: user.school }
  let(:level_1) { create :level, :one, course: course_1 }
  let(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_1) { create :target, :for_founders, target_group: target_group_1 }
  let!(:target_2) { create :target, :for_team, target_group: target_group_1 }
  let!(:submission_by_student) { create :timeline_event, :with_owners, latest: true, owners: [student], target: target_1 }
  let!(:submission_by_team) { create :timeline_event, :with_owners, latest: true, owners: student_with_teammates.startup.founders, target: target_1 }

  # Create coach enrollments, connect_slots, startup feedback, evaluated submissions and coach notes by user
  let!(:coach_course_enrollment) { create :faculty_course_enrollment, course: course, faculty: coach }
  let!(:team_2) { create :startup, level: level_1 }
  let!(:coach_team_enrollment) { create :faculty_startup_enrollment, startup: team_2, faculty: coach }
  let!(:coach_note_by_user) { create :coach_note, author: user, student: team_2.founders.first }
  let!(:connect_slot) { create :connect_slot, faculty: coach }
  let!(:submission_reviewed_by_user) { create :timeline_event, :with_owners, latest: true, owners: team_2.founders, target: target_1, evaluator: coach, evaluated_at: Time.zone.now }

  # Create community records
  let!(:post) { create :post, creator: user, topic: create(:topic) }
  let!(:post_like) { create :post_like, user: user, post: post }


  # Miscellaneous records
  let!(:issued_certificate_for_user) { create :issued_certificate, user: user }
  let!(:markdown_attachment_by_user) { create :markdown_attachment, user: user }
  let!(:course_export) { create :course_export, :teams, user: user, course: course }

  describe '#execute' do
    context 'user is an admin in school' do
      before do
        create(:school_admin, user: user, school: user.school)
      end
      it 'an exception is raised' do
        expect { subject.execute }.to raise_error('user is a school admin')
      end
    end

    context 'user is not an admin in school' do
      before do
        post.text_versions.create!(value: post.body, user: user, edited_at: post.updated_at)
      end
      it 'deletes data and nullifies references in applicable records' do
        subject.execute

        # Check only applicable records are destroyed
        expect(User.find_by(id: user.id)).to eq(nil)
        expect(Founder.find_by(id: student.id)).to eq(nil)
        expect(Startup.find_by(id: student_team.id)).to eq(nil)
        expect(Startup.find_by(id: team_with_user.id)).to_not eq(nil)
        expect(TimelineEventOwner.where(founder_id: user.founders.select(:id))).to eq([])
        expect(TimelineEvent.find_by(id: submission_by_student.id)).to eq(nil)
        expect(TimelineEvent.find_by(id: submission_by_team.id)).to_not eq(nil)
        expect(submission_by_team.founders.pluck(:id).sort).to eq(team_with_user.founders.reload.pluck(:id).sort)
        expect(CourseAuthor.find_by(id: course_author.id)).to eq(nil)
        expect(Faculty.find_by(id: coach.id)).to eq(nil)
        expect(CoachNote.find_by(id: coach_note_1.id)).to eq(nil)
        expect(FacultyCourseEnrollment.find_by(id: coach_course_enrollment.id)).to eq(nil)
        expect(FacultyStartupEnrollment.find_by(id: coach_team_enrollment.id)).to eq(nil)
        expect(ConnectSlot.find_by(id: connect_slot.id)).to eq(nil)

        # Check user_id is nullified in applicable records
        expect(coach_note_by_user.reload.author_id).to eq(nil)
        expect(submission_reviewed_by_user.reload.evaluator_id).to eq(nil)
        expect(post.reload.creator_id).to eq(nil)
        expect(post_like.reload.user_id).to eq(nil)
        expect(post.text_versions.first.user_id).to eq(nil)
        expect(issued_certificate_for_user.reload.user_id).to eq(nil)
        expect(markdown_attachment_by_user.reload.user_id).to eq(nil)
        expect(course_export.reload.user_id).to eq(nil)
      end
    end
  end
end
