require "rails_helper"

feature "Cohorts", js: true do
  include UserSpecHelper

  let!(:school) { create :school, :current }

  let!(:course_coach) { create :faculty, school: school }

  let!(:course) { create :course, school: school }

  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }

  let!(:target_group_l1) { create :target_group, level: level_1 }

  let!(:target_group_l2) { create :target_group, level: level_2 }

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

  let(:cohort_1) { create :cohort, course: course }
  let(:cohort_2) { create :cohort, course: course }
  let(:cohort_3) { create :cohort, course: course, ends_at: 1.day.ago }
  let(:cohort_4) { create :cohort, course: course }

  # Create few students
  let!(:student_1) do
    create :student, tag_list: ["starts with z", "vegetable"], cohort: cohort_1
  end # This will always be around the bottom of the list.
  let!(:student_2) do
    create :student, tag_list: ["vegetable"], cohort: cohort_1
  end # This will always be around the top.
  let!(:student_3) { create :student, cohort: cohort_1 }
  let!(:student_4) { create :student, cohort: cohort_1 }
  let!(:student_5) { create :student, cohort: cohort_1 }
  let!(:student_6) { create :student, cohort: cohort_1 }

  before do
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort_1
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort_2
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort_3
    student_1.user.update!(name: "Zucchini", last_seen_at: 3.minutes.ago)
    student_2.user.update!(name: "Asparagus")
    student_3.user.update!(name: "Banana")
    student_4.user.update!(name: "Blueberry")
    student_5.user.update!(name: "Cherry")
    student_6.user.update!(name: "Elderberry")

    30.times do
      user = create :user, name: "C #{Faker::Lorem.word} #{rand(10)}"

      create :student, cohort: cohort_1, user: user
    end

    5.times do
      user = create :user, name: "A #{Faker::Lorem.word} #{rand(10)}"

      # These will be around the top of the list.
      create :student, cohort: cohort_2, user: user
    end

    3.times do
      user = create :user, name: "B #{Faker::Lorem.word} #{rand(10)}"

      create :student, cohort: cohort_3, user: user
    end
  end

  context "when the user is a course coach" do
    scenario "can see all the active cohorts where they are a coach" do
      sign_in_user course_coach.user, referrer: cohorts_course_path(course)

      expect(page).to have_text(course.name)

      expect(page).to have_text("41 students enrolled in 2 active cohorts")

      expect(page).to have_text("Active Cohorts")

      expect(page).to have_text(cohort_1.name)
      expect(page).to have_text(cohort_2.name)
      expect(page).not_to have_text(cohort_4.name)
    end

    scenario "can see all the the ended cohorts where they are a coach" do
      sign_in_user course_coach.user,
                   referrer: cohorts_course_path(course, status: "ended")

      expect(page).to have_text(course.name)

      expect(page).to have_text("3 students enrolled in 1 ended cohort")

      expect(page).to have_text("Ended Cohorts")

      expect(page).to have_text(cohort_3.name)
    end

    scenario "visits an active cohort page" do
      sign_in_user course_coach.user, referrer: cohorts_course_path(course)

      click_link cohort_1.name

      expect(page).to have_text(cohort_1.name)

      expect(page).to have_text(course.name)

      expect(page).to have_text("Overview")

      expect(page).to have_text("Students")

      expect(page).to have_text("Student Distribution by Milestone Completion")

      expect(page).to have_text("M1: " + target_l1.title)
      expect(page).to have_text("M2: " + target_l2.title)
      expect(page).to have_text("0/36", count: 2)

      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_1],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      visit cohort_path(cohort_1)

      expect(page).to have_text("1/36", count: 1)
      expect(page).to have_text("3%", count: 1)

      visit students_cohort_path(cohort_1)
      expect(page).to have_current_path(students_cohort_path(cohort_1))
    end

    context "with an archived submission" do
      scenario "archived submissions are not counted in the cohort overview or students pages" do
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: [student_2],
          target: target_l1,
          evaluator_id: course_coach.id,
          evaluated_at: 2.days.ago,
          passed_at: 3.days.ago,
          archived_at: 1.day.ago
        )

        sign_in_user course_coach.user, referrer: cohort_path(cohort_1)

        # The count of completions of both assignments should remain at zero.
        expect(page).to have_text("0/36", count: 2)

        visit students_cohort_path(cohort_1)

        # It's showing all students now, so Student 2's name should be there.
        expect(page).to have_text(student_2.name)

        fill_in "Filter", with: "M"
        click_button "Milestone completed: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"

        # Student 2's name should not be listed in the page anymore.
        expect(page).not_to have_text(student_2.name)
      end
    end

    scenario "visits the students tab inside a cohort" do
      sign_in_user course_coach.user, referrer: cohorts_course_path(course)

      visit students_cohort_path(cohort_1)

      expect(page).to have_text(student_1.name)
      expect(page).to have_text(student_2.name)

      visit student_report_path(student_1)
      expect(page).to have_current_path(student_report_path(student_1))

      expect(page).to have_text(student_1.name)
      expect(page).to have_text("Milestones")
    end

    scenario "filters the students by email" do
      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      fill_in "Filter", with: student_1.email
      click_button "Search by email address: #{student_1.email}"

      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)

      find("button[title='Remove selection: #{student_1.email}']").click
      expect(page).to have_text(student_2.name)
    end

    scenario "filters the students by name" do
      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      fill_in "Filter", with: student_1.name
      click_button "Search by name: #{student_1.name}"

      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)

      find("button[title='Remove selection: #{student_1.name}']").click
      expect(page).to have_text(student_2.name)
    end

    scenario "filters the students by milestone completion" do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_1],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      fill_in "Filter", with: "M"
      click_button "Milestone completed: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"

      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)

      find(
        "button[title='Remove selection: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}']"
      ).click
      expect(page).to have_text(student_2.name)
    end

    scenario "filters the students by milestone pending" do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_1],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      fill_in "Filter", with: "M"
      click_button "Milestone incomplete: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"

      expect(page).not_to have_text(student_1.name)
      expect(page).to have_text(student_2.name)

      find(
        "button[title='Remove selection: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}']"
      ).click
      expect(page).to have_text(student_2.name)
      expect(page).to have_text(student_1.name)
    end

    scenario "filters the students by course completion" do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_1],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_1],
        target: target_l2,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      student_1.update!(completed_at: 3.days.ago)

      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      fill_in "Filter", with: "Completed"
      click_button "Course completion: Completed"

      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)

      find("button[title='Remove selection: Completed']").click
      expect(page).to have_text(student_2.name)
    end

    scenario "visits the students tab by clicking on milestone pill" do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_1],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      sign_in_user course_coach.user, referrer: cohort_path(cohort_1)

      find(
        "a[href='#{students_cohort_path(cohort_1, milestone_completed: "#{target_l1.id};M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}")}']"
      ).click

      expect(page).to have_current_path(
        students_cohort_path(
          cohort_1,
          milestone_completed:
            "#{target_l1.id};M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"
        )
      )

      expect(page).to have_text(student_1.name)

      visit cohort_path(cohort_1)

      find(
        "a[href='#{students_cohort_path(cohort_1, milestone_completed: "#{target_l2.id};M#{target_l2.assignments.first.milestone_number}: #{target_l2.title}")}']"
      ).click

      expect(page).to have_current_path(
        students_cohort_path(
          cohort_1,
          milestone_completed:
            "#{target_l2.id};M#{target_l2.assignments.first.milestone_number}: #{target_l2.title}"
        )
      )

      expect(page).to have_text(
        "There are no students matching the selected filters."
      )
    end

    scenario "pagination is present when the students are more than 24" do
      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      expect(page).to have_text(
        "Now showing 1-24 of a total of 36 such students."
      )
    end

    scenario "should show the remaining students in the next page" do
      sign_in_user course_coach.user, referrer: students_cohort_path(cohort_1)

      click_link "2"

      expect(page).to have_text(
        "Now showing 25-36 of a total of 36 such students."
      )
    end
  end

  context "when the user isn't signed in" do
    scenario "user is required to sign in" do
      visit cohorts_course_path(course)

      expect(page).to have_text("Sign in to #{school.name}")
    end
  end

  context "when the user is a student" do
    scenario "user is not allowed to view the page" do
      sign_in_user student_1.user, referrer: cohorts_course_path(course)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end
end
