require "rails_helper"

describe DailyDigestService do
  include ActiveSupport::Testing::TimeHelpers
  include HtmlSanitizerSpecHelper

  subject { described_class.new }

  around(:each) do |example|
    # Time travel to the test time when running a spec.
    travel_to(Time.zone.parse("2019-07-16T18:00:00+05:30")) { example.run }
  end

  let(:school) { create :school, :current }

  describe "#execute" do
    context 'when there are more than 5 new topics and 5 "re-activated" older topics' do
      let(:course_1) { create :course, school: school }
      let(:cohort_1) { create :cohort, course: course_1 }
      let(:level_1) { create :level, :one, course: course_1 }
      let(:team_1) { create :team, cohort: cohort_1 }

      let(:course_2) { create :course, school: school }
      let(:cohort_2) { create :cohort, course: course_2 }
      let(:level_2) { create :level, :one, course: course_2 }
      let(:team_2) { create :team, cohort: cohort_2 }

      let(:t1_student) { create :student, team: team_1, cohort: cohort_1 }
      let(:t2_student) { create :student, team: team_2, cohort: cohort_2 }

      let!(:community_1) do
        create :community,
               name: "First Community",
               school: school,
               courses: [course_1, course_2]
      end
      let!(:community_2) do
        create :community,
               name: "Second Community",
               school: school,
               courses: [course_2]
      end

      let!(:t1_user) { t1_student.user }
      let!(:t2_user) { t2_student.user }

      let!(:topic_c1_new_1) do
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user,
               views: 10
      end
      let!(:topic_c1_new_2) do
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user,
               views: 20
      end
      let!(:topic_c1_new_archived) do
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user,
               views: 100,
               archived: true
      end
      let!(:topic_c1_reactivated_1) do
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user,
               created_at: 2.days.ago,
               views: 10
      end
      let!(:topic_c1_reactivated_2) do
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user,
               created_at: 3.days.ago,
               views: 20
      end
      let!(:topic_c1_reactivated_archived) do
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user,
               created_at: 4.days.ago,
               views: 100,
               archived: true
      end
      let!(:topic_c1_old) do
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user,
               created_at: 5.days.ago,
               views: 100
      end
      let!(:topic_c2_new_1) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               views: 30
      end
      let!(:topic_c2_new_2) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               views: 40
      end
      let!(:topic_c2_new_3) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               views: 50
      end
      let!(:topic_c2_new_4) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               views: 60
      end
      let!(:topic_c2_reactivated_1) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               created_at: 2.days.ago,
               views: 30
      end
      let!(:topic_c2_reactivated_2) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               created_at: 3.days.ago,
               views: 40
      end
      let!(:topic_c2_reactivated_3) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               created_at: 4.days.ago,
               views: 50
      end
      let!(:topic_c2_reactivated_4) do
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t2_user,
               created_at: 5.days.ago,
               views: 60
      end

      before do
        # Add a second post for all the "re-activated" topics.
        create :post,
               creator: t1_user,
               topic: topic_c1_reactivated_1,
               post_number: 2,
               created_at: 1.hour.ago
        create :post,
               creator: t1_user,
               topic: topic_c1_reactivated_2,
               post_number: 2,
               created_at: 1.hour.ago
        create :post,
               creator: t1_user,
               topic: topic_c1_reactivated_archived,
               post_number: 2,
               created_at: 1.hour.ago
        create :post,
               creator: t2_user,
               topic: topic_c2_reactivated_1,
               post_number: 2,
               created_at: 1.hour.ago
        create :post,
               creator: t2_user,
               topic: topic_c2_reactivated_2,
               post_number: 2,
               created_at: 1.hour.ago
        create :post,
               creator: t2_user,
               topic: topic_c2_reactivated_3,
               post_number: 2,
               created_at: 1.hour.ago
        create :post,
               creator: t2_user,
               topic: topic_c2_reactivated_4,
               post_number: 2,
               created_at: 1.hour.ago
      end

      it "sends digest emails containing 5 most popular newly posted topics and older topics with new activity" do
        subject.execute
        open_email(t1_user.email)

        subject_1 = current_email.subject
        expect(subject_1).to include(school.name)
        expect(subject_1).to include("Daily Digest")
        expect(subject_1).to include("Jul 16, 2019")

        body_1 = sanitize_html(current_email.body)

        expect(body_1).to include(t1_user.name)

        # This email should only mention the first community.
        expect(body_1).to include(community_1.name)
        expect(body_1).not_to include(community_2.name)

        # It should include all topics in first community except the archived ones.
        expect(body_1).to include(topic_c1_new_1.title)
        expect(body_1).to include(topic_c1_new_2.title)
        expect(body_1).not_to include(topic_c1_new_archived.title)
        expect(body_1).to include(topic_c1_reactivated_1.title)
        expect(body_1).to include(topic_c1_reactivated_2.title)
        expect(body_1).not_to include(topic_c1_reactivated_archived.title)

        # It should not include any topics from second community.
        expect(body_1).not_to include(topic_c2_new_1.title)
        expect(body_1).not_to include(topic_c2_new_4.title)
        expect(body_1).not_to include(topic_c2_reactivated_1.title)
        expect(body_1).not_to include(topic_c2_reactivated_4.title)

        open_email(t2_user.email)

        subject_2 = current_email.subject

        # Subject should be identical to first.
        expect(subject_2).to eq(subject_1)

        body_2 = sanitize_html(current_email.body)

        # It should have only 5 of the most popular topics from both communities.
        expect(body_2).not_to include(topic_c1_new_1.title)
        expect(body_2).to include(topic_c1_new_2.title)
        expect(body_2).to include(topic_c2_new_1.title)
        expect(body_2).to include(topic_c2_new_2.title)
        expect(body_2).to include(topic_c2_new_3.title)
        expect(body_2).to include(topic_c2_new_4.title)
        expect(body_2).not_to include(topic_c1_reactivated_1.title)
        expect(body_2).to include(topic_c1_reactivated_2.title)
        expect(body_2).to include(topic_c2_reactivated_1.title)
        expect(body_2).to include(topic_c2_reactivated_2.title)
        expect(body_2).to include(topic_c2_reactivated_3.title)
        expect(body_2).to include(topic_c2_reactivated_4.title)
      end

      context "when there is a student whose access has ended" do
        let(:ended_cohort) { create :cohort, ends_at: 1.day.ago }
        let(:team_access_ended) { create :team, cohort: ended_cohort }
        let(:student_access_ended) do
          create :student, team: team_access_ended, cohort: cohort_1
        end
        let!(:user_access_ended) { student_access_ended.user }
        let(:community_1) do
          create :community, school: school, courses: [team_access_ended.course]
        end
        let(:community_2) do
          create :community, school: school, courses: [team_access_ended.course]
        end

        it "does not send digest to student whose access has ended" do
          subject.execute
          open_email(user_access_ended.email)
          expect(current_email).to eq(nil)
        end
      end

      context "when there is a dropped out student" do
        let(:team_dropped_out) { create :team, cohort: cohort_1 }
        let(:student_dropped_out) do
          create :student,
                 team: team_dropped_out,
                 dropped_out_at: 1.day.ago,
                 cohort: cohort_1
        end
        let!(:user_dropped_out) { student_dropped_out.user }
        let(:community_1) do
          create :community, school: school, courses: [team_dropped_out.course]
        end
        let(:community_2) do
          create :community, school: school, courses: [team_dropped_out.course]
        end

        it "does not send digest to dropped out student" do
          subject.execute
          open_email(user_dropped_out.email)
          expect(current_email).to eq(nil)
        end
      end

      context "when a student has opted-out of the daily digest" do
        let(:student_opt_out) { create :student, team: team_2 }
        let!(:user_opt_out) { student_opt_out.user }

        before { user_opt_out.update!(preferences: { daily_digest: false }) }

        it "does not send daily digest" do
          subject.execute
          open_email(user_opt_out.email)
          expect(current_email).to eq(nil)
        end
      end

      context "when a user has a bounced email address" do
        let(:student_bounced) { create :student, team: team_2 }
        let!(:user_bounced) { student_bounced.user }

        before do
          BounceReport.create!(
            email: user_bounced.email,
            bounce_type: "HardBounce"
          )
        end

        it "does not send daily digest" do
          subject.execute
          open_email(user_bounced.email)
          expect(current_email).to eq(nil)
        end
      end
    end

    context "when the user is a coach" do
      let(:course_1) { create :course, school: school }
      let(:cohort_1) { create :cohort, course: course_1 }
      let(:level_1) { create :level, :one, course: course_1 }
      let(:target_group_1) { create :target_group, level: level_1 }
      let!(:target_1) do
        create :target,
               :with_shared_assignment,
               given_role: Assignment::ROLE_STUDENT,
               target_group: target_group_1
      end
      let(:grade_labels_for_1) do
        [
          { "grade" => 1, "label" => "Okay" },
          { "grade" => 2, "label" => "Good" },
          { "grade" => 3, "label" => "Great" },
          { "grade" => 4, "label" => "Wow" }
        ]
      end
      let(:evaluation_criterion_1) do
        create :evaluation_criterion,
               course: course_1,
               max_grade: 4,
               grade_labels: grade_labels_for_1
      end

      let(:team_1) { create :team_with_students, cohort: cohort_1 }
      let!(:submission_pending_1) do
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: team_1.students,
          target: target_1
        )
      end

      let(:course_2) { create :course, school: school }
      let(:cohort_2) { create :cohort, course: course_2 }
      let(:level_2) { create :level, :one, course: course_2 }
      let(:target_group_2) { create :target_group, level: level_2 }
      let!(:target_2) do
        create :target,
               :with_shared_assignment,
               given_role: Assignment::ROLE_STUDENT,
               target_group: target_group_2
      end
      let(:grade_labels_for_2) do
        [
          { "grade" => 1, "label" => "Okay" },
          { "grade" => 2, "label" => "Good" },
          { "grade" => 3, "label" => "Great" },
          { "grade" => 4, "label" => "Wow" }
        ]
      end
      let(:evaluation_criterion_2) do
        create :evaluation_criterion,
               course: course_2,
               max_grade: 4,
               grade_labels: grade_labels_for_2
      end

      let(:team_2) { create :team_with_students, cohort: cohort_2 }
      let!(:submission_pending_2) do
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: team_2.students,
          target: target_2
        )
      end
      let!(:submission_pending_3) do
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: team_2.students,
          target: target_2
        )
      end
      let(:submission_pending_4) do
        create(:timeline_event, target: target_1, created_at: 2.weeks.ago)
      end

      let(:coach) { create :faculty, school: school }
      let(:team_coach) { create :faculty, school: school }

      let(:community_1) do
        create :community, school: school, courses: [course_1]
      end
      let(:t1_user) { team_1.students.first.user }

      let(:course_3) { create :course, school: school }
      let(:cohort_3) { create :cohort, course: course_3 }
      let(:level_3) { create :level, :one, course: course_3 }
      let(:team_3) { create :team_with_students, cohort: cohort_3 }
      let(:community_2) do
        create :community, school: school, courses: [course_3]
      end
      let(:t3_user) { team_3.students.first.user }
      let(:coach_2) { create :faculty, school: school }

      before do
        create :faculty_cohort_enrollment, faculty: coach, cohort: cohort_1
        create :faculty_cohort_enrollment, faculty: coach, cohort: cohort_2
        create :faculty_cohort_enrollment, faculty: team_coach, cohort: cohort_1
        create :faculty_cohort_enrollment, faculty: team_coach, cohort: cohort_2
        create :faculty_student_enrollment,
               faculty: team_coach,
               student: team_2.students.first
        create :faculty_cohort_enrollment, faculty: coach_2, cohort: cohort_3
        create :topic,
               :with_first_post,
               community: community_1,
               creator: t1_user
        create :topic,
               :with_first_post,
               community: community_2,
               creator: t3_user

        target_1.assignments.first.evaluation_criteria << evaluation_criterion_1
        target_2.assignments.first.evaluation_criteria << evaluation_criterion_2
      end

      it "sends coaches info about submissions to review and community updates" do
        subject.execute

        open_email(coach.user.email)
        b = sanitize_html(current_email.body)

        expect(b).to include(course_1.name)
        expect(b).to include(course_2.name)
        expect(b).to include(
          "There are 3 new submissions to review in the courses you're coaching"
        )

        # The email should include community updates, but only
        # from the courses where the coach is enrolled.
        expect(b).to include(community_1.name)
        expect(b).not_to include(community_2.name)
      end

      it "sends team coaches the number submissions from students assigned to them" do
        subject.execute

        open_email(team_coach.user.email)

        b = sanitize_html(current_email.body)

        expect(b).to include(course_1.name)
        expect(b).to include(course_2.name)
        expect(b).to include("(2 from students assigned to you)")
        expect(b).not_to include("(0 from students assigned to you)")
      end

      it "only sends community updates where coach is enrolled to a linked course" do
        subject.execute

        open_email(coach_2.user.email)

        b = sanitize_html(current_email.body)

        expect(b).not_to include(course_1.name)
        expect(b).not_to include(community_1.name)
        expect(b).to include(community_2.name)
      end

      context "when there is only one submission pending review" do
        before do
          submission_pending_2.destroy!
          submission_pending_3.destroy!
        end

        it "mentions that there is only one submission to review" do
          subject.execute
          open_email(coach.user.email)
          b = sanitize_html(current_email.body)

          expect(b).to include(
            "There is 1 new submission to review in a course you're coaching"
          )
        end
      end
    end

    context "when there are no updates" do
      let(:school_2) { create :school }
      let(:course_1) { create :course, school: school_2 }
      let(:cohort_1) { create :cohort, course: course_1 }
      let(:level_1) { create :level, :one, course: course_1 }
      let(:target_group_1) { create :target_group, level: level_1 }
      let!(:target_1) do
        create :target,
               :with_shared_assignment,
               given_role: Assignment::ROLE_STUDENT,
               target_group: target_group_1
      end
      let(:grade_labels_for_1) do
        [
          { "grade" => 1, "label" => "Okay" },
          { "grade" => 2, "label" => "Good" },
          { "grade" => 3, "label" => "Great" },
          { "grade" => 4, "label" => "Wow" }
        ]
      end
      let(:evaluation_criterion_1) do
        create :evaluation_criterion,
               course: course_1,
               max_grade: 4,
               grade_labels: grade_labels_for_1
      end

      let(:team_1) { create :team, cohort: cohort_1 }
      let(:coach) { create :faculty, school: school_2 }
      let(:team_coach) { create :faculty, school: school_2 }

      before do
        create :domain, school: school_2
        create :faculty_cohort_enrollment, faculty: coach, cohort: cohort_1
      end

      it "should not trigger email" do
        subject.execute

        open_email(coach.user.email)
        expect(current_email).to eq(nil)
      end
    end
  end
end
