require "rails_helper"

feature "Organisation student details page and submissions list" do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let!(:organisation) { create :organisation, school: school }
  let!(:organisation_2) { create :organisation, school: school }
  let(:org_admin_user) { create :user, school: school }

  let!(:org_admin) do
    create :organisation_admin, organisation: organisation, user: org_admin_user
  end

  let(:course) { create :course }
  let(:faculty) { create :faculty }

  let(:evaluation_criterion_1) { create :evaluation_criterion, course: course }
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }

  let(:target_group_l1) { create :target_group, level: level_1 }
  let(:target_group_l2) { create :target_group, level: level_2 }
  let(:target_group_l3) { create :target_group, level: level_3 }

  let(:target_l1_1) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l1,
           given_evaluation_criteria: [
             evaluation_criterion_1,
             evaluation_criterion_2
           ],
           given_milestone_number: 1
  end

  let(:target_l1_2) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l1,
           given_evaluation_criteria: [
             evaluation_criterion_1,
             evaluation_criterion_2
           ],
           given_milestone_number: 2
  end

  let(:target_l2) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l1,
           given_evaluation_criteria: [evaluation_criterion_1],
           given_milestone_number: 2
  end

  let!(:target_l3) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l3,
           given_evaluation_criteria: [evaluation_criterion_2]
  end

  let!(:archived_assignment) do
    create :assignment,
            :with_default_checklist,
            archived: true,
            role: Assignment::ROLE_STUDENT
  end

  let!(:target_with_archived_assignment) do
    create :target,
            target_group: target_group_l3,
            assignments: [archived_assignment]
  end

  let(:cohort) { create :cohort, course: course }
  let(:cohort_inactive) { create :cohort, course: course, ends_at: 1.day.ago }

  let(:student_user) do
    create :user,
           name: "Student in main cohort",
           email: "student_main@example.com",
           school: school,
           last_seen_at: 1.week.ago,
           organisation: organisation
  end

  let(:student) { create :student, user: student_user, cohort: cohort }

  let!(:student_from_another_org) do
    user =
      create :user,
             name: "Student From Another Org",
             email: "another_org_student@example.com",
             school: school,
             organisation: organisation_2

    create :student, user: user, cohort: cohort
  end

  let!(:student_in_inactive_cohort) do
    user =
      create :user,
             name: "Student In Inactive Cohort",
             email: "inactive_cohort_student@example.com",
             school: school,
             organisation: organisation

    create :student, user: user, cohort: cohort_inactive
  end

  let!(:coach_note) do
    create :coach_note, student: student, author: faculty.user
  end

  before do
    # Enroll faculty in cohort.
    create :faculty_cohort_enrollment, faculty: faculty, cohort: cohort

    # Create evaluated L1 submissions for student.
    (1..11).each do |i|
      latest = i == 11

      te =
        create :timeline_event,
               :evaluated,
               :with_owners,
               owners: [student],
               latest: latest,
               target: target_l1_1,
               evaluator: faculty,
               created_at: i.days.ago,
               passed_at: i % 2 == 0 ? nil : (i.days.ago + 1.hour)

      create :timeline_event_grade,
             timeline_event: te,
             evaluation_criterion: evaluation_criterion_1,
             grade: i % 2 == 0 ? 1 : 2

      create :timeline_event_grade,
             timeline_event: te,
             evaluation_criterion: evaluation_criterion_2,
             grade: i % 2 == 0 ? 2 : 3
    end

    # Create one reviewed submission on the second L2 target.
    te_l1_2 =
      create :timeline_event,
             :evaluated,
             :with_owners,
             owners: [student],
             latest: true,
             target: target_l1_2,
             evaluator: faculty,
             passed_at: 1.day.ago

    create :timeline_event_grade,
           timeline_event: te_l1_2,
           evaluation_criterion: evaluation_criterion_1,
           grade: 1

    create :timeline_event_grade,
           timeline_event: te_l1_2,
           evaluation_criterion: evaluation_criterion_2,
           grade: 2
  end

  # Create one submission pending review in L2 for student.
  let!(:timeline_event_pending) do
    create :timeline_event,
           :with_owners,
           owners: [student],
           latest: true,
           target: target_l2
  end

  let!(:page_read_1) do
    create :page_read, student: student, target: target_with_archived_assignment
  end

  let!(:mark_as_read_target) { create :target, target_group: target_group_l3 }
  let!(:page_read_2)  { create(:page_read, student: student, target: mark_as_read_target) }

  let!(:submission_target_with_archived_assignment) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: target_with_archived_assignment,
      passed_at: 1.day.ago
    )
  end

  context "when the user isn't signed in" do
    scenario "user is required to sign in" do
      visit org_student_path(student)

      expect(page).to have_text("Sign in to #{school.name}")
    end
  end

  context "when the user is a school admin" do
    let(:school_admin_user) { create :user, school: school }

    let!(:school_admin) do
      create :school_admin, school: school, user: school_admin_user
    end

    scenario "admin visiting an org student page is shown details" do
      sign_in_user school_admin_user, referrer: org_student_path(student)

      expect(page).to have_text(student.name)

      expect(page).to have_text("Cohort")
      expect(page).to have_text(cohort.name)

      expect(page).to have_text "Targets Overview"
    end
  end

  context "when the user is an org admin" do
    scenario "org admin can see all details of a student", js: true do
      sign_in_user org_admin_user, referrer: org_student_path(student)

      # Check name.
      expect(page).to have_text(student.name)

      expect(page).to have_text("Cohort")
      expect(page).to have_text(cohort.name)

      expect(page).to have_text("Targets Overview")

      # Check assignment completion stats.
      expect(page).to have_text(
        "50%\nTotal Assignments Completed\n2/4 Assignments"
      )

      # Check targets reads.
      expect(page).to have_text(
        "33%\nTotal Targets Read\n2/6 Targets"
      )

      # Check average grades.
      expect(page).to have_text("1.5/3\n#{evaluation_criterion_1.name}")
      expect(page).to have_text("2.5/3\n#{evaluation_criterion_2.name}")

      # Check notes.
      expect(page).to have_text(coach_note.note)

      # Check pending submissions...
      expect(page).to have_link(
        target_l2.title,
        href: timeline_event_path(timeline_event_pending)
      )
    end

    scenario "org admin can access a list of all previously reviewed submissions" do
      sign_in_user org_admin_user, referrer: org_student_path(student)

      click_link "View previously reviewed submissions"

      expect(page).to have_text("Total\n12\nAccepted\n7\nRejected\n5")

      expect(page).to have_link(target_l1_2.title, count: 1)
      expect(page).to have_link(target_l1_1.title, count: 9)

      # Try the second page.
      click_link("2")

      expect(page).to have_link(target_l1_1.title, count: 2)
    end

    scenario "org admin can access details of a student of inactive cohort" do
      sign_in_user org_admin_user,
                   referrer: org_student_path(student_in_inactive_cohort)

      expect(page).to have_text(student_in_inactive_cohort.name)
      expect(page).to have_text "Targets Overview"
    end

    scenario "org admin cannot access details of a student in another org" do
      sign_in_user org_admin_user,
                   referrer: org_student_path(student_from_another_org)

      expect(page.status_code).to eq(404)
    end

    context "when the org admin is also a student" do
      let(:student_org_admin) do
        create :student, user: org_admin_user, cohort: cohort
      end

      let!(:coach_note) do
        create :coach_note, student: student_org_admin, author: faculty.user
      end

      before { org_admin_user.update!(organisation: organisation) }

      scenario "org admin cannot see private notes" do
        sign_in_user org_admin_user,
                     referrer: org_student_path(student_org_admin)

        expect(page).to have_text(org_admin_user.name)
        expect(page).not_to have_text("Notes")
        expect(page).not_to have_text(coach_note.note)
      end
    end

    scenario "org student page does not show standing info when school standing is disabled" do
      sign_in_user org_admin_user, referrer: org_student_path(student)

      expect(page).not_to have_text("View Standing")
    end

    context "when school standing is enabled" do
      before { school.update!(configuration: { enable_standing: true }) }
      let!(:standing) { create :standing, school: school, default: true }

      scenario "org student page shows the standing info" do
        sign_in_user org_admin_user, referrer: org_student_path(student)

        expect(page).to have_text("View Standing")
        expect(page).to have_text(standing.name)

        click_link "View Standing"
        expect(page).to have_current_path(standing_org_student_path(student))
      end
    end
  end
end
