require "rails_helper"

feature "Public preview of course curriculum", js: true do
  include MarkdownEditorHelper
  include UserSpecHelper

  # The basics.
  let(:public_course_1) { create :course, public_preview: true }
  let!(:public_course_2) { create :course, public_preview: true }
  let!(:private_course_3) { create :course }

  let(:evaluation_criterion) do
    create :evaluation_criterion, course: public_course_1
  end

  # Levels.
  let(:level_1) { create :level, :one, course: public_course_1 }
  let(:level_2) { create :level, :two, course: public_course_1 }

  let(:locked_level_3) do
    create :level, :three, course: public_course_1, unlock_at: 1.month.from_now
  end

  # Target groups.
  let(:target_group_l1) { create :target_group, level: level_1 }

  let(:target_group_l2) { create :target_group, level: level_2 }

  let(:target_group_l3) { create :target_group, level: locked_level_3 }

  # Individual targets of different types.
  let!(:target_l1) do
    create :target,
           :with_markdown,
           :with_shared_assignment,
           given_evaluation_criteria: [evaluation_criterion],
           target_group: target_group_l1,
           given_role: Assignment::ROLE_TEAM
  end

  let!(:quiz) { create :quiz, :with_question_and_answers }

  let!(:target_l2) do
    create :target, :with_markdown, target_group: target_group_l2
  end
  let!(:assignment_target_l2) do
    create :assignment,
           target: target_l2,
           role: Assignment::ROLE_TEAM,
           quiz: quiz,
           checklist: []
  end

  let!(:target_l3) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l3,
           given_role: Assignment::ROLE_TEAM
  end

  scenario "user can preview course curriculum" do
    visit curriculum_course_path(public_course_1)

    expect(page).to have_text("Preview Mode")

    # Course name should be displayed.
    expect(page).to have_content(public_course_1.name)

    # One other public course should also be displayed.
    click_button public_course_1.name

    expect(page).to have_link(
      public_course_2.name,
      href: curriculum_course_path(public_course_2)
    )

    expect(page).not_to have_link(private_course_3.name)

    # The first level should be selected, and all other levels should be visible.
    click_button "L1: #{level_1.name}"

    expect(page).to have_button("L2: #{level_2.name}")
    expect(page).to have_button("L3: #{locked_level_3.name}")

    click_button "L2: #{level_2.name}"

    expect(page).to have_content(target_group_l2.name)
    expect(page).to have_content(target_group_l2.description)
    expect(page).to have_content(target_l2.title)

    # Let's try taking the quiz.
    click_link target_l2.title

    expect(page).to have_content(
      "You are currently looking at a preview of this course."
    )

    find(".course-overlay__body-tab-item", text: "Take Quiz").click

    expect(page).to have_content(/Question #1/i)

    find(".quiz-root__answer", match: :first).click

    expect(page).to have_button("Submit Quiz", disabled: true)

    # Let's check out the submission option on L1.
    click_button "Close"
    click_button "L2: #{level_2.name}"
    click_button "L1: #{level_1.name}"

    # Let's try taking the quiz.
    click_link target_l1.title

    expect(page).to have_content(
      "You are currently looking at a preview of this course."
    )

    find(".course-overlay__body-tab-item", text: "Complete").click

    # The submit button should be disabled.
    expect(page).to have_button("Submit", disabled: true)

    replace_markdown Faker::Lorem.sentence

    # The submit button should still be disabled.
    expect(page).to have_button("Submit", disabled: true)

    # Let's try to access a locked level.
    click_button "Close"

    click_button "L1: #{level_1.name}"
    click_button "L3: #{locked_level_3.name}"

    expect(page).to have_text("The level is currently locked")
    expect(page).to have_text("You can access the content on")
  end

  context "when the course has level zero enabled" do
    let(:level_0) { create :level, :zero, course: public_course_1 }
    let(:target_group_l0) { create :target_group, level: level_0 }

    before do
      create :target,
             :with_shared_assignment,
             target_group: target_group_l0,
             given_role: Assignment::ROLE_TEAM
    end

    scenario "user can preview level zero" do
      visit curriculum_course_path(public_course_1)

      expect(page).to have_button(level_0.name)
      expect(page).to have_content("L1: #{level_1.name}")
    end
  end

  context "when the user is a student in another course" do
    let(:enrolled_course) { create :course, :with_cohort }
    let!(:l_1) { create :level, :one, course: enrolled_course }
    let(:student) { create :student, cohort: enrolled_course.cohorts.first }

    scenario "student in one course accesses preview of another course" do
      sign_in_user student.user,
                   referrer: curriculum_course_path(enrolled_course)

      expect(page).to have_content(enrolled_course.name)

      # Access the public course's preview by visiting its page manually.
      visit curriculum_course_path(public_course_1)

      # There should now be a dropdown that lets the student access his enrolled courses.
      click_button public_course_1.name

      expect(page).to have_link(
        enrolled_course.name,
        href: curriculum_course_path(enrolled_course)
      )

      expect(page).to have_text("Preview Mode")
    end
  end

  scenario "private courses cannot be viewed by public" do
    visit curriculum_course_path(private_course_3)

    expect(page).to have_text("Please sign in to continue")
  end
end
