require "rails_helper"

feature "Organisation show" do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let!(:organisation) { create :organisation, school: school }
  let!(:organisation_2) { create :organisation, school: school }
  let(:org_admin_user) { create :user, school: school }

  let!(:org_admin) do
    create :organisation_admin, organisation: organisation, user: org_admin_user
  end

  let(:course) { create :course }

  let!(:course_coach) { create :faculty, school: school }

  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }

  let!(:target_group_l1) { create :target_group, level: level_1 }
  let!(:target_group_l2) { create :target_group, level: level_2 }
  let!(:target_group_l3) { create :target_group, level: level_3 }

  let!(:target_l1) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l1,
           given_role: Assignment::ROLE_STUDENT,
           given_evaluation_criteria: [evaluation_criterion],
           given_milestone_number: 1
  end

  let!(:target_l2) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l2,
           given_role: Assignment::ROLE_STUDENT,
           given_evaluation_criteria: [evaluation_criterion],
           given_milestone_number: 2
  end

  let!(:target_l3) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l3,
           given_role: Assignment::ROLE_STUDENT,
           given_evaluation_criteria: [evaluation_criterion],
           given_milestone_number: 3
  end

  let(:cohort) { create :cohort, course: course }
  let(:cohort_2) { create :cohort, course: course }
  let(:cohort_inactive) { create :cohort, course: course, ends_at: 1.day.ago }

  let!(:students) do
    (1..30).map do |i|
      user =
        create :user,
               name: "Student #{i}",
               email: "student#{i}@example.com",
               school: school,
               last_seen_at: 1.week.ago,
               organisation: organisation

      create :student, user: user, cohort: cohort
    end
  end

  let!(:student_from_another_org) do
    user =
      create :user,
             name: "Student From Another Org",
             email: "another_org_student@example.com",
             school: school,
             organisation: organisation_2

    create :student, user: user, cohort: cohort
  end

  let!(:student_from_another_cohort) do
    user =
      create :user,
             name: "Student From Another Cohort",
             email: "another_cohort_student@example.com",
             school: school,
             organisation: organisation

    create :student, user: user, cohort: cohort_2
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

  context "when the user is an organisation admin" do
    scenario "user can paginate through all students" do
      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      expect(page).to have_selector('[data-test-class="student"]', count: 24)
      expect(page).not_to have_text(student_from_another_cohort.name)
      expect(page).not_to have_text(student_from_another_org.name)

      click_link "2"

      expect(page).to have_selector('[data-test-class="student"]', count: 6)
      expect(page).not_to have_text(student_from_another_cohort.name)
      expect(page).not_to have_text(student_from_another_org.name)
    end

    scenario "user can filter by email", js: true do
      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      student = students[15]
      fill_in "Filter", with: student.email
      click_button "Search by email address: #{student.email}"

      expect(page).to have_text("Search by email address: #{student.email}")
      expect(page).to have_selector('[data-test-class="student"]', count: 1)
      expect(page).to have_link(student.name)
    end

    scenario "user can filter by name", js: true do
      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      student = students[15]
      fill_in "Filter", with: student.name
      click_button "Search by name: #{student.name}"

      expect(page).to have_text("Search by name: #{student.name}")
      expect(page).to have_selector('[data-test-class="student"]', count: 1)

      expect(page).to have_text(
        "#{student.user.full_title} | Last seen 7 days ago"
      )
    end

    scenario "user can filter by milestone completed", js: true do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [students.first],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      fill_in "Filter", with: "M"
      click_button "Milestone completed: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"

      expect(page).to have_text(students.first.name)
      expect(page).not_to have_text(students.second.name)

      find(
        "button[title='Remove selection: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}']"
      ).click
      expect(page).to have_text(students.second.name)
    end

    scenario "user can filter by milestone pending", js: true do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [students.first],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      fill_in "Filter", with: "M"
      click_button "Milestone incomplete: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"

      expect(page).not_to have_content("#{students.first.name}\n")
      expect(page).to have_text(students.second.name)

      find(
        "button[title='Remove selection: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}']"
      ).click
      expect(page).to have_text(students.first.name)
    end

    scenario "user can filter by course completion", js: true do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [students.first],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [students.first],
        target: target_l2,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [students.first],
        target: target_l3,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      students.first.update!(completed_at: 3.days.ago)

      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      fill_in "Filter", with: "Completed"
      click_button "Course completion: Completed"

      expect(page).to have_text(students.first.name)
      expect(page).not_to have_text(students.second.name)

      find("button[title='Remove selection: Completed']").click
      expect(page).to have_text(students.second.name)
    end

    scenario "user can sort results using different criteria", js: true do
      middle_student_1 = students[15]
      middle_student_2 = students[16]

      middle_student_1.user.update!(last_seen_at: 1.day.ago)
      middle_student_2.user.update!(last_seen_at: 1.month.ago)

      middle_student_1.update!(created_at: 1.day.ago)
      middle_student_2.update!(created_at: 1.day.from_now)

      middle_student_1.user.update!(name: "Zatanna Zatara")
      middle_student_2.user.update!(name: "Amanda Waller")

      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      expect(
        page.find('[data-test-class="student"]', match: :first)
      ).to have_text(middle_student_1.name)

      click_button "Recently Seen"
      click_button "First Created"

      expect(
        page.find('[data-test-class="student"]', match: :first)
      ).to have_text(middle_student_1.name)

      click_button "First Created"
      click_button "Earliest Seen"

      expect(
        page.find('[data-test-class="student"]', match: :first)
      ).to have_text(middle_student_2.name)

      click_button "Earliest Seen"
      click_button "Last Created"

      expect(
        page.find('[data-test-class="student"]', match: :first)
      ).to have_text(middle_student_2.name)

      click_button "Last Created"
      click_button "Name"

      expect(
        page.find('[data-test-class="student"]', match: :first)
      ).to have_text(middle_student_2.name)
    end

    scenario "user can access list of students of inactive course" do
      sign_in_user org_admin_user,
                   referrer:
                     students_organisation_cohort_path(
                       organisation,
                       cohort_inactive
                     )

      expect(page).to have_link(
        student_in_inactive_cohort.name,
        href: org_student_path(student_in_inactive_cohort)
      )
    end
  end

  context "when the user is a school admin" do
    let(:school_admin_user) { create :user, school: school }

    let!(:school_admin) do
      create :school_admin, school: school, user: school_admin_user
    end

    scenario "user can access list of students of active course" do
      sign_in_user school_admin_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      expect(page).to have_text(
        "Now showing 1-24 of a total of 30 such students"
      )
    end

    scenario "user can access list of students of inactive course" do
      sign_in_user school_admin_user,
                   referrer:
                     students_organisation_cohort_path(
                       organisation,
                       cohort_inactive
                     )

      expect(page).to have_link(
        student_in_inactive_cohort.name,
        href: org_student_path(student_in_inactive_cohort)
      )
    end
  end

  context "when the user is a regular user" do
    let(:regular_user) { create :user, school: school }

    scenario "user cannot access list of students in a cohort" do
      sign_in_user regular_user,
                   referrer:
                     students_organisation_cohort_path(organisation, cohort)

      expect(page).to have_http_status(:not_found)
    end
  end
end
