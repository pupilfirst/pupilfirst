require 'rails_helper'

describe DailyDigestService do
  include ActiveSupport::Testing::TimeHelpers
  include HtmlSanitizerSpecHelper

  subject { described_class.new }

  around(:each) do |example|
    # Time travel to the test time when running a spec.
    travel_to(Time.zone.parse('2019-07-16T18:00:00+05:30')) do
      example.run
    end
  end

  let(:school) { create :school, :current }

  describe '#execute' do
    context 'when there are more than 5 topics with no activity in the past seven days' do
      let(:team_1) { create :startup }
      let(:team_2) { create :team }
      let(:team_3) { create :startup }
      let(:team_4) { create :team, dropped_out_at: 1.day.ago }

      let(:t2_student_regular) { create :founder, startup: team_2 }
      let(:t2_student_digest_inactive) { create :founder, startup: team_2 }
      let(:t2_student_bounced) { create :founder, startup: team_2 }
      let(:t4_student_dropped_out) { create :founder, startup: team_4 }

      let(:community_1) { create :community, school: school, courses: [team_1.course] }
      let(:community_2) { create :community, school: school, courses: [team_1.course, team_2.course] }
      let(:community_3) { create :community, school: school, courses: [team_1.course, team_2.course, team_3.course, team_4.course] }

      let(:t1_user) { team_1.founders.first.user }
      let(:t2_user_1) { t2_student_regular.user }
      let(:t2_user_2) { t2_student_digest_inactive.user }
      let(:t2_user_3) { t2_student_bounced.user }
      let(:t3_user) { team_3.founders.first.user }
      let(:t4_user) { t4_student_dropped_out.user }

      let!(:topic_c1) { create :topic, :with_first_post, community: community_1, creator: t1_user }
      let!(:topic_c2_1) { create :topic, :with_first_post, community: community_2, creator: t2_user_1 }
      let!(:topic_c2_2) { create :topic, :with_first_post, community: community_2, creator: t2_user_2 }
      let!(:topic_c3_1) { create :topic, :with_first_post, community: community_3, created_at: 2.days.ago, creator: t3_user, archived: true }
      let!(:topic_c3_2) { create :topic, :with_first_post, community: community_3, created_at: 3.days.ago, creator: t3_user }
      let!(:topic_c3_3) { create :topic, :with_first_post, community: community_3, created_at: 8.days.ago, creator: t3_user }

      before do
        # Turn off daily digest for the disabled user.
        t2_user_2.update!(preferences: { daily_digest: false })

        # Create bounce report for t2_student_bounced.
        BounceReport.create!(email: t2_student_bounced.email, bounce_type: 'HardBounce')
      end

      it 'sends digest emails containing details about new topics and one without responses' do
        subject.execute

        open_email(t1_user.email)

        s1 = current_email.subject
        expect(s1).to include(school.name)
        expect(s1).to include('Daily Digest')
        expect(s1).to include('Jul 16, 2019')

        b1 = sanitize_html(current_email.body)

        # The email should link to all three communities.
        expect(b1).to include(community_1.name)
        expect(b1).to include(community_2.name)
        expect(b1).to include(community_3.name)

        # It should include all topics except the archived one and the one from 8 days ago.
        expect(b1).to include(topic_c1.title)
        expect(b1).to include(topic_c2_1.title)
        expect(b1).to include(topic_c2_2.title)
        expect(b1).to include(topic_c3_2.title)
        expect(b1).not_to include(topic_c3_1.title)
        expect(b1).not_to include(topic_c3_3.title)

        open_email(t2_user_1.email)

        s2 = current_email.subject

        # Subject should be identical to first.
        expect(s2).to eq(s1)

        b2 = sanitize_html(current_email.body)

        # It should not have topics from the first community and one from 8 days ago.
        expect(b2).not_to include(topic_c1.title)
        expect(b2).to include(topic_c2_1.title)
        expect(b2).to include(topic_c2_2.title)
        expect(b2).to include(topic_c3_2.title)
        expect(b2).not_to include(topic_c3_1.title)
        expect(b2).not_to include(topic_c3_3.title)

        # User from team 2 with daily digest turned off shouldn't receive the mail.
        open_email(t2_user_2.email)
        expect(current_email).to eq(nil)

        # User from team 2 whose email bounced shouldn't receive email.
        open_email(t2_user_3.email)
        expect(current_email).to eq(nil)

        # Dropped out user shouldn't receive email.
        open_email(t4_user.email)
        expect(current_email).to eq(nil)

        open_email(t3_user.email)

        s3 = current_email.subject

        # Subject should be identical to first.
        expect(s3).to eq(s1)

        b3 = sanitize_html(current_email.body)

        # It should only have the one topic from third community.
        expect(b3).not_to include(topic_c1.title)
        expect(b3).not_to include(topic_c2_1.title)
        expect(b3).not_to include(topic_c2_2.title)
        expect(b3).to include(topic_c3_2.title)
        expect(b3).not_to include(topic_c3_1.title)
        expect(b3).not_to include(topic_c3_3.title)
      end

      context 'when there are more than 5 topics with no activity in the past seven days' do
        let!(:topic_c3_3) { create :topic, :with_first_post, community: community_3, created_at: 2.days.ago, creator: t1_user }
        let!(:topic_c3_archived) { create :topic, :with_first_post, community: community_3, created_at: 3.days.ago, archived: true, creator: t2_user_1 }
        let!(:topic_c3_4) { create :topic, :with_first_post, community: community_3, created_at: 3.days.ago, creator: t2_user_1 }
        let!(:topic_c3_5) { create :topic, :with_first_post, community: community_3, created_at: 4.days.ago, creator: t2_user_2 }
        let!(:topic_c3_6) { create :topic, :with_first_post, community: community_3, created_at: 5.days.ago, creator: t3_user }
        let!(:topic_c3_7) { create :topic, :with_first_post, community: community_3, created_at: 6.days.ago, creator: t1_user }
        let!(:topic_c3_8) { create :topic, :with_first_post, community: community_3, created_at: 6.days.ago, creator: t2_user_1 }
        let!(:reply) { create :post, topic: topic_c3_6, creator: t3_user, post_number: 2 }

        it 'only mails up to 5 such topics' do
          subject.execute

          open_email(t3_user.email)

          b = sanitize_html(current_email.body)

          expect(b).not_to include(topic_c1.title)
          expect(b).not_to include(topic_c2_1.title)
          expect(b).not_to include(topic_c2_2.title)
          expect(b).to include(topic_c3_2.title)
          expect(b).not_to include(topic_c3_archived.title) # topic was archived.
          expect(b).to include(topic_c3_3.title)
          expect(b).not_to include(topic_c3_8.title)
          expect(b).to include(topic_c3_4.title)
          expect(b).to include(topic_c3_5.title)
          expect(b).not_to include(topic_c3_6.title) # topic was commented on.
          expect(b).to include(topic_c3_7.title)
          expect(b).not_to include(topic_c3_8.title)
        end
      end
    end

    context 'when the user is a faculty' do
      let(:course_1) { create :course, school: school }
      let(:level_1) { create :level, :one, course: course_1 }
      let(:target_group_1) { create :target_group, level: level_1 }
      let!(:target_1) { create :target, :for_founders, target_group: target_group_1 }
      let(:grade_labels_for_1) { [{ 'grade' => 1, 'label' => 'Bad' }, { 'grade' => 2, 'label' => 'Good' }, { 'grade' => 3, 'label' => 'Great' }, { 'grade' => 4, 'label' => 'Wow' }] }
      let(:evaluation_criterion_1) { create :evaluation_criterion, course: course_1, max_grade: 4, pass_grade: 2, grade_labels: grade_labels_for_1 }

      let(:team_1) { create :startup, level: level_1 }
      let(:submission_pending_1) { create(:timeline_event, latest: true, target: target_1) }

      let(:course_2) { create :course, school: school }
      let(:level_2) { create :level, :one, course: course_2 }
      let(:target_group_2) { create :target_group, level: level_2 }
      let!(:target_2) { create :target, :for_founders, target_group: target_group_2 }
      let(:grade_labels_for_2) { [{ 'grade' => 1, 'label' => 'Bad' }, { 'grade' => 2, 'label' => 'Good' }, { 'grade' => 3, 'label' => 'Great' }, { 'grade' => 4, 'label' => 'Wow' }] }
      let(:evaluation_criterion_2) { create :evaluation_criterion, course: course_2, max_grade: 4, pass_grade: 2, grade_labels: grade_labels_for_2 }

      let(:team_2) { create :startup, level: level_2 }
      let(:submission_pending_2) { create(:timeline_event, latest: true, target: target_2) }
      let(:submission_pending_3) { create(:timeline_event, latest: true, target: target_2) }
      let(:submission_pending_4) { create(:timeline_event, latest: true, target: target_1, created_at: 2.weeks.ago) }

      let(:coach) { create :faculty, school: school }
      let(:team_coach) { create :faculty, school: school }

      let(:community_1) { create :community, school: school, courses: [course_1] }
      let(:t1_user) { team_1.founders.first.user }

      let(:course_3) { create :course, school: school }
      let(:level_3) { create :level, :one, course: course_3 }
      let(:team_3) { create :startup, level: level_3 }
      let(:community_2) { create :community, school: school, courses: [course_3] }
      let(:t3_user) { team_3.founders.first.user }
      let(:coach_2) { create :faculty, school: school }

      before do
        create :faculty_course_enrollment, faculty: coach, course: course_1
        create :faculty_course_enrollment, faculty: coach, course: course_2
        create :faculty_course_enrollment, faculty: team_coach, course: course_1
        create :faculty_course_enrollment, faculty: team_coach, course: course_2
        create :faculty_startup_enrollment, faculty: team_coach, startup: team_2
        create :faculty_course_enrollment, faculty: coach_2, course: course_3
        create :topic, :with_first_post, community: community_1, creator: t1_user
        create :topic, :with_first_post, community: community_2, creator: t3_user

        submission_pending_1.founders << team_1.founders
        submission_pending_2.founders << team_2.founders
        submission_pending_3.founders << team_2.founders
        target_1.evaluation_criteria << evaluation_criterion_1
        target_2.evaluation_criteria << evaluation_criterion_2
      end

      it 'When the user is a course coach' do
        subject.execute

        open_email(coach.user.email)

        b = sanitize_html(current_email.body)
        expect(b).to include(course_1.name)
        expect(b).to include(course_2.name)
        expect(b).to include("There are 3")
        expect(b).to include("new submissions to review")
        expect(b).to include("in 2 courses")

        # The email should include community updates
        expect(b).to include(community_1.name)
        expect(b).not_to include(community_2.name)
      end

      it 'When the user is a team coach' do
        subject.execute

        open_email(team_coach.user.email)

        b = sanitize_html(current_email.body)

        expect(b).to include(course_1.name)
        expect(b).to include(course_2.name)
        expect(b).to include("(2 assigned to you)")
        expect(b).not_to include("(none of which are assigned to you)")
      end

      it "when the coach doesn't have review access to all courses" do
        subject.execute

        open_email(coach_2.user.email)

        b = sanitize_html(current_email.body)

        expect(b).not_to include(course_1.name)
        expect(b).not_to include(community_1.name)
        expect(b).to include(community_2.name)
      end
    end
  end

  context 'when there are no updates' do
    let(:school_2) { create :school }
    let(:course_1) { create :course, school: school_2 }
    let(:level_1) { create :level, :one, course: course_1 }
    let(:target_group_1) { create :target_group, level: level_1 }
    let!(:target_1) { create :target, :for_founders, target_group: target_group_1 }
    let(:grade_labels_for_1) { [{ 'grade' => 1, 'label' => 'Bad' }, { 'grade' => 2, 'label' => 'Good' }, { 'grade' => 3, 'label' => 'Great' }, { 'grade' => 4, 'label' => 'Wow' }] }
    let(:evaluation_criterion_1) { create :evaluation_criterion, course: course_1, max_grade: 4, pass_grade: 2, grade_labels: grade_labels_for_1 }

    let(:team_1) { create :startup, level: level_1 }
    let(:coach) { create :faculty, school: school_2 }
    let(:team_coach) { create :faculty, school: school_2 }

    before do
      create :domain, school: school_2
      create :faculty_course_enrollment, faculty: coach, course: course_1
    end

    it 'should not trigger email' do
      subject.execute

      open_email(coach.user.email)
      expect(current_email).to eq(nil)
    end
  end
end
