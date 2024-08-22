require "rails_helper"

feature "Target Details Editor", js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper

  # Setup a course with few targets target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:faculty) { create :faculty, school: school }
  let!(:course_author) do
    create :course_author, course: course, user: faculty.user
  end
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_group_2) { create :target_group, level: level_2 }
  let!(:target_1_l1) do
    create :target, :with_shared_assignment, target_group: target_group_1
  end
  let!(:target_1_l2) do
    create :target, :with_shared_assignment, target_group: target_group_2
  end
  let!(:target_non_assignment_l2) do
    create :target, :with_content, target_group: target_group_2
  end
  let!(:target_2_l2) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_2,
           given_evaluation_criteria: [evaluation_criterion]
  end
  let!(:target_3_l2) do
    create :target, :with_shared_assignment, target_group: target_group_2
  end
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:link_to_complete) { Faker::Internet.url }
  let(:completion_instructions) { Faker::Lorem.sentence }
  let(:new_target_title) { Faker::Lorem.sentence }

  let(:quiz_question_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_2) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3_hint) { Faker::Lorem.sentence }
  let(:quiz_question_2) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_2) { Faker::Lorem.sentence }

  scenario "school admin adds and removes assignment from a non assignment target" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find(
      "a[title='Edit details of target #{target_non_assignment_l2.title}']"
    ).click
    expect(page).to have_text("Title")

    expect(page).to_not have_content("Is this assignment a milestone?")
    expect(page).to_not have_content(
      "Does this assignment have any prerequisites?"
    )
    expect(page).to_not have_content(
      "Will a coach review submissions on this assignment?"
    )

    within("div#has_assignment") { click_button "Yes" }

    expect(page).to have_content("Is this assignment a milestone?")
    expect(page).to have_content("Does this assignment have any prerequisites?")
    expect(page).to have_content(
      "Will a coach review submissions on this assignment?"
    )

    within("div#evaluated") { click_button "No" }

    expect(page).to have_button("Submit a form to complete the target.")
    within("div#method_of_completion") do
      click_button "Submit a form to complete the target."
    end

    expect(page).to_not have_text("evaluation criteria")

    find("button", text: "Add another question").click
    checklist_question = Faker::Lorem.sentence
    replace_markdown(checklist_question, id: "checklist-item-1-title")

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_non_assignment_l2.reload.assignments.first).to_not eq(nil)
    expect(target_non_assignment_l2.assignments.first.checklist).to_not eq(nil)

    #moving a target with assignment to no assignment doesn't delete assignment data

    within("div#has_assignment") { click_button "No" }
    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_non_assignment_l2.reload.assignments.first).to_not eq(nil)
    expect(target_non_assignment_l2.reload.assignments.first.archived).to eq(
      true
    )

    within("div#has_assignment") { click_button "Yes" }
    expect(page).to have_text(checklist_question)
  end

  scenario "school admin removes assignment from a prerequisite target" do
    prerequisite_target =
      create :target, :with_content, target_group: target_group_2

    assignment_prerequisite_target =
      create :assignment,
             :with_default_checklist,
             prerequisite_assignments: [target_3_l2.assignments.first],
             role: Assignment::ROLE_STUDENT,
             target: prerequisite_target

    target_2_l2.assignments.first.prerequisite_assignments = [
      assignment_prerequisite_target
    ]

    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{prerequisite_target.title}']").click
    expect(page).to have_text("Title")

    expect(page).to have_content("Is this assignment a milestone?")
    expect(
      target_2_l2.reload.assignments.first.prerequisite_assignments
    ).to_not eq([])
    expect(
      prerequisite_target.reload.assignments.first.prerequisite_assignments
    ).to_not eq([])

    within("div#has_assignment") { click_button "No" }

    expect(page).to_not have_content("Is this assignment a milestone?")

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    # Removing an assignment removes all prerequisite relations
    expect(target_2_l2.reload.assignments.first.prerequisite_assignments).to eq(
      []
    )
    expect(
      prerequisite_target.reload.assignments.first.prerequisite_assignments
    ).to eq([])
  end

  scenario "school admin makes a target milestone when there is another existing milestone" do
    create :target,
           :with_content,
           :with_shared_assignment,
           target_group: target_group_2,
           given_milestone_number: 1

    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the assignment target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text("Title")

    # Change it to a milestone
    within("div#milestone") { click_button "Yes" }
    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")

    #Make sure the assignment milestone number is incremented correctly
    expect(target_1_l2.reload.assignments.first.milestone_number).to eq(2)
  end

  scenario "school admin modifies title and adds completion instruction to target" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text("Title")

    # Cache current sort index
    current_sort_index = target_1_l2.sort_index

    fill_in "title", with: new_target_title, fill_options: { clear: :backspace }
    fill_in "completion-instructions", with: completion_instructions

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.title).to eq(new_target_title)
    expect(target_1_l2.assignments.first.completion_instructions).to eq(
      completion_instructions
    )

    # Check sort index is unaffected
    expect(target_1_l2.sort_index).to eq(current_sort_index)

    # Clears the completion instructions

    fill_in "completion-instructions",
            with: "",
            fill_options: {
              clear: :backspace
            }

    click_button "Update Target"
    dismiss_notification

    expect(
      target_1_l2.reload.assignments.first.completion_instructions
    ).to be_nil
  end

  scenario "school admin updates a target as reviewed by faculty" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text("Title")

    fill_in "title", with: new_target_title, fill_options: { clear: :backspace }

    within("div#evaluated") { click_button "Yes" }

    expect(page).to_not have_button("Visit a link to complete the target.")
    expect(page).to have_text("At least one has to be selected")

    find("button[title='Select #{evaluation_criterion.display_name}']").click

    within("div#visibility") { click_button "Live" }

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.title).to eq(new_target_title)
    expect(target_1_l2.visibility).to eq(Target::VISIBILITY_LIVE)
    expect(target_1_l2.assignments.first.evaluation_criteria.count).to eq(1)
    expect(target_1_l2.assignments.first.evaluation_criteria.first.name).to eq(
      evaluation_criterion.name
    )
  end

  scenario "school admin updates a target to one with submit a form" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text("Title")

    fill_in "title", with: new_target_title, fill_options: { clear: :backspace }

    within("div#evaluated") { click_button "No" }

    expect(page).to have_button("Submit a form to complete the target.")
    within("div#method_of_completion") do
      click_button "Submit a form to complete the target."
    end
    expect(page).to have_text(
      "What are the questions you would like the student to answer?"
    )
    expect(page).to_not have_text("At least one has to be selected")

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.title).to eq(new_target_title)
    expect(target_1_l2.visibility).to eq(Target::VISIBILITY_LIVE)
    expect(target_1_l2.assignments.first.evaluation_criteria.count).to eq(0)
  end

  scenario "school admin updates a target to one with quiz" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_2_l2.title}']").click
    expect(page).to have_text("Title")

    within("div#evaluated") { click_button "No" }

    within("div#method_of_completion") do
      click_button "Take a quiz to complete the target."
    end

    # Quiz Question 1
    replace_markdown(quiz_question_1, id: "quiz-question-1")
    fill_in "quiz-question-1-answer-option-1",
            with: quiz_question_1_answer_option_1
    fill_in "quiz-question-1-answer-option-2",
            with: quiz_question_1_answer_option_2
    find("button", text: "Add another Answer Option").click
    fill_in "quiz-question-1-answer-option-3",
            with: quiz_question_1_answer_option_3

    within("div#quiz-question-1-answer-option-3-block") do
      click_button "Mark as correct"
    end

    # Quiz Question 2
    find("button", text: "Add another question").click
    replace_markdown(quiz_question_2, id: "quiz-question-2")
    fill_in "quiz-question-2-answer-option-1",
            with: quiz_question_2_answer_option_1
    fill_in "quiz-question-2-answer-option-2",
            with: quiz_question_2_answer_option_2

    click_button "Update Target"

    expect(page).to have_text("Target updated successfully")

    dismiss_notification

    target = target_2_l2.reload

    expect(target.assignments.first.evaluation_criteria).to eq([])
    expect(target.assignments.first.quiz.quiz_questions.count).to eq(2)
    expect(target.assignments.first.quiz.quiz_questions.first.question).to eq(
      quiz_question_1
    )
    expect(
      target.assignments.first.quiz.quiz_questions.first.correct_answer.value
    ).to eq(quiz_question_1_answer_option_3)
    expect(target.assignments.first.quiz.quiz_questions.last.question).to eq(
      quiz_question_2
    )
    expect(
      target.assignments.first.quiz.quiz_questions.last.correct_answer.value
    ).to eq(quiz_question_2_answer_option_1)
  end

  scenario "school admin updates a target to one with submit a form" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_2_l2.title}']").click
    expect(page).to have_text("Title")

    within("div#evaluated") { click_button "No" }

    expect(page).to have_button("Submit a form to complete the target.")
    within("div#method_of_completion") do
      click_button "Submit a form to complete the target."
    end

    expect(page).to_not have_text("evaluation criteria")

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(
      target_2_l2.reload.assignments.first.evaluation_criteria.count
    ).to eq(0)
    expect(target_2_l2.assignments.first.quiz).to eq(nil)
    expect(target_2_l2.visibility).to eq(Target::VISIBILITY_LIVE)
  end

  scenario "course author modifies target role and prerequisite targets" do
    draft_target =
      create :target,
             :with_shared_assignment,
             :draft,
             target_group: target_group_2
    archived_target =
      create :target,
             :with_shared_assignment,
             :archived,
             target_group: target_group_2

    sign_in_user course_author.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text("Does this assignment have any prerequisites?")

    within("div#prerequisite_targets") do
      expect(page).to have_text(target_2_l2.title)
      expect(page).to have_text(draft_target.title)
      expect(page).not_to have_text(archived_target.title)
      expect(page).to have_text(target_1_l1.title)

      find("button[title='Select #{target_2_l2.title}']").click
      find("button[title='Select #{draft_target.title}']").click
    end

    click_button "Only one student in a team needs to submit."

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.assignments.first.role).to eq(
      Assignment::ROLE_TEAM
    )
    expect(target_1_l2.assignments.first.prerequisite_assignments.count).to eq(
      2
    )
    expect(
      target_1_l2.assignments.first.prerequisite_assignment_ids
    ).to contain_exactly(
      target_2_l2.assignments.first.id,
      draft_target.assignments.first.id
    )

    # Assigns prerequisites to draft target
    sign_in_user course_author.user,
                 referrer:
                   details_school_course_target_path(
                     course_id: course.id,
                     id: draft_target.id
                   )

    within("div#prerequisite_targets") do
      expect(page).to have_text(target_2_l2.title)

      find("button[title='Select #{target_2_l2.title}']").click
    end

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")

    expect(
      draft_target.reload.assignments.first.prerequisite_assignment_ids
    ).to eq([target_2_l2.assignments.first.id])
  end

  scenario "user is notified on reloading window if target editor has unsaved changes" do
    pending "Unable to test because of https://issues.chromium.org/issues/42323840"

    sign_in_user course_author.user,
                 referrer:
                   details_school_course_target_path(
                     course_id: course.id,
                     id: target_1_l2.id
                   )

    expect(page).to have_text("Does this assignment have any prerequisites?")

    # Can refresh the page without any confirm dialog
    refresh

    fill_in "title", with: new_target_title, fill_options: { clear: :backspace }

    # Need to confirm if page is refreshed with unsaved data.
    accept_confirm { refresh }
  end

  context "when targets have an existing checklist" do
    let!(:target_2_l2) do
      create :target,
             :with_shared_assignment,
             target_group: target_group_2,
             given_evaluation_criteria: [evaluation_criterion]
    end

    let(:checklist_with_multiple_items) do
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => "Write something about your submission",
          "optional" => false
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_SHORT_TEXT,
          "title" => "Write something short about your submission",
          "optional" => true
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_LINK,
          "title" => "Attach link for your submission",
          "optional" => true
        }
      ]
    end

    let!(:target_3_l2) { create :target, target_group: target_group_2 }

    let!(:assignment_target_3_l2) do
      create :assignment,
             target: target_3_l2,
             checklist: checklist_with_multiple_items,
             evaluation_criteria: [evaluation_criterion]
    end

    let!(:quiz_target) do
      create :target, :with_shared_assignment, target_group: target_group_2
    end
    let(:quiz) { create :quiz, target: quiz_target }
    let(:quiz_question) { create :quiz_question, :with_answers, quiz: quiz }

    let!(:submission_for_quiz_target_with_grades) do
      create(
        :timeline_event,
        target: quiz_target,
        evaluated_at: 1.day.ago,
        passed_at: nil
      )
    end

    let!(:timeline_event_grade) do
      create(
        :timeline_event_grade,
        timeline_event: submission_for_quiz_target_with_grades,
        evaluation_criterion: evaluation_criterion,
        grade: 2
      )
    end

    let!(:submission_for_quiz_target_without_grades) do
      create(
        :timeline_event,
        target: quiz_target,
        evaluated_at: nil,
        passed_at: 1.day.ago
      )
    end

    scenario "admin expands the existing checklist in an evaluated target" do
      sign_in_user course_author.user,
                   referrer:
                     details_school_course_target_path(
                       course_id: course.id,
                       id: target_2_l2.id
                     )
      expect(page).to have_text(
        "What steps should the student take to complete this assignment?"
      )

      # Change the existing item
      within("div[aria-label='Editor for checklist item 1'") do
        click_on "Write Long Text"
        expect(page).to have_text("Write Short Text")
        expect(page).to have_text("Attach a Link")
        expect(page).to have_text("Choose from a list")

        click_on "Write Short Text"
        fill_in "checklist-item-1-title",
                with: "New title for short text item",
                fill_options: {
                  clear: :backspace
                }
      end

      # Add few more checklist items of different kind
      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 2'") do
        click_on "Write Long Text"
        click_on "Upload Files"
        fill_in "checklist-item-2-title",
                with: "Add a file for the submission",
                fill_options: {
                  clear: :backspace
                }
        check "Optional"
      end

      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 3'") do
        click_on "Write Long Text"

        click_on "Choose from a list"

        expect(page).to have_text("Choices:")

        fill_in "checklist-item-3-title",
                with: "Choose one item",
                fill_options: {
                  clear: :backspace
                }

        expect(page).to_not have_selector(".i-times-regular")

        check "Allow multiple selections"

        fill_in "multichoice-input-1",
                with: "First Choice",
                fill_options: {
                  clear: :backspace
                }
        fill_in "multichoice-input-2",
                with: "Second Choice",
                fill_options: {
                  clear: :backspace
                }
        click_button "Add a choice"

        expect(page).to have_text("Not a valid choice")
        expect(page).to have_selector(".i-times-regular")

        fill_in "multichoice-input-3",
                with: "Another Choice",
                fill_options: {
                  clear: :backspace
                }
        click_button "Remove Choice 2"
      end

      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 4'") do
        expect(page).to have_text("Question cannot be empty")

        click_on "Write Long Text"
        click_on "Attach a Link"
        fill_in "checklist-item-4-title",
                with: "New title for short text item",
                fill_options: {
                  clear: :backspace
                }

        # The user should be blocked from saving the checklist with duplicate required steps.
        expect(page).to have_text("required questions must be unique")
      end

      expect(page).to have_button("Update Target", disabled: true)

      # The warning should disappear when we make the step optional.
      within("div[aria-label='Editor for checklist item 4'") do
        check "Optional"

        expect(page).not_to have_text("required questions must be unique")

        fill_in "checklist-item-4-title",
                with: "Attach a link for the submission",
                fill_options: {
                  clear: :backspace
                }
      end

      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 5'") do
        expect(page).to have_text("Question cannot be empty")

        click_on "Write Long Text"
        click_on "Record Audio"
        fill_in "checklist-item-5-title",
                with: "Title for audio item",
                fill_options: {
                  clear: :backspace
                }
      end

      click_button "Update Target"

      expect(page).to have_text("Target updated successfully")

      dismiss_notification

      expected_checklist = [
        {
          "kind" => Assignment::CHECKLIST_KIND_SHORT_TEXT,
          "title" => "New title for short text item",
          "metadata" => {
          },
          "optional" => false
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_FILES,
          "title" => "Add a file for the submission",
          "metadata" => {
          },
          "optional" => true
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_MULTI_CHOICE,
          "title" => "Choose one item",
          "metadata" => {
            "choices" => ["First Choice", "Another Choice"],
            "allowMultiple" => true
          },
          "optional" => false
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_LINK,
          "title" => "Attach a link for the submission",
          "metadata" => {
          },
          "optional" => true
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_AUDIO,
          "title" => "Title for audio item",
          "metadata" => {
          },
          "optional" => false
        }
      ]

      expect(target_2_l2.reload.assignments.first.checklist).to eq(
        expected_checklist
      )
    end

    scenario "admin changes the target with an existing checklist to a form submission" do
      sign_in_user course_author.user,
                   referrer:
                     details_school_course_target_path(
                       course_id: course.id,
                       id: target_2_l2.id
                     )
      expect(page).to have_text(
        "What steps should the student take to complete this assignment?"
      )

      # Change the existing item
      within("div[aria-label='Editor for checklist item 1'") do
        click_on "Write Long Text"
        expect(page).to have_text("Write Short Text")
        expect(page).to have_text("Attach a Link")
        expect(page).to have_text("Choose from a list")

        click_on "Write Short Text"
        fill_in "checklist-item-1-title",
                with: "New title for short text item",
                fill_options: {
                  clear: :backspace
                }
      end

      # Add few more checklist items of different kind
      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 2'") do
        click_on "Write Long Text"
        click_on "Upload Files"
        fill_in "checklist-item-2-title",
                with: "Add a file for the submission",
                fill_options: {
                  clear: :backspace
                }
        check "Optional"
      end

      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 3'") do
        click_on "Write Long Text"

        click_on "Choose from a list"

        expect(page).to have_text("Choices:")

        fill_in "checklist-item-3-title",
                with: "Choose one item",
                fill_options: {
                  clear: :backspace
                }

        expect(page).to_not have_selector(".i-times-regular")

        fill_in "multichoice-input-1",
                with: "First Choice",
                fill_options: {
                  clear: :backspace
                }
        fill_in "multichoice-input-2",
                with: "Second Choice",
                fill_options: {
                  clear: :backspace
                }
        click_button "Add a choice"

        expect(page).to have_text("Not a valid choice")
        expect(page).to have_selector(".i-times-regular")

        fill_in "multichoice-input-3",
                with: "Another Choice",
                fill_options: {
                  clear: :backspace
                }
        click_button "Remove Choice 2"
      end

      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 4'") do
        expect(page).to have_text("Question cannot be empty")

        click_on "Write Long Text"
        click_on "Attach a Link"
        fill_in "checklist-item-4-title",
                with: "New title for short text item",
                fill_options: {
                  clear: :backspace
                }

        # The user should be blocked from saving the checklist with duplicate required steps.
        expect(page).to have_text("required questions must be unique")
      end

      expect(page).to have_button("Update Target", disabled: true)

      # The warning should disappear when we make the step optional.
      within("div[aria-label='Editor for checklist item 4'") do
        check "Optional"

        expect(page).not_to have_text("required questions must be unique")

        fill_in "checklist-item-4-title",
                with: "Attach a link for the submission",
                fill_options: {
                  clear: :backspace
                }
      end

      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 5'") do
        expect(page).to have_text("Question cannot be empty")

        click_on "Write Long Text"
        click_on "Record Audio"
        fill_in "checklist-item-5-title",
                with: "Title for audio item",
                fill_options: {
                  clear: :backspace
                }
      end

      # click_button 'Update Target'

      # expect(page).to have_text('Target updated successfully')

      # dismiss_notification

      # expect(target_2_l2.reload.checklist).to eq(expected_checklist)

      within("div#evaluated") { click_button "No" }
      within("div#method_of_completion") do
        click_button "Submit a form to complete the target."
      end
      expect(page).to have_text(
        "What are the questions you would like the student to answer?"
      )
      expect(page).to have_button("Add another question")
      expect(page).to_not have_text("evaluation criteria")

      click_button "Add another question"

      within("div[aria-label='Editor for checklist item 6'") do
        expect(page).to have_text("Question cannot be empty")

        click_on "Write Long Text"
        click_on "Record Audio"
        fill_in "checklist-item-6-title",
                with: "Title for audio item 2",
                fill_options: {
                  clear: :backspace
                }
      end

      expected_checklist = [
        {
          "kind" => Assignment::CHECKLIST_KIND_SHORT_TEXT,
          "title" => "New title for short text item",
          "metadata" => {
          },
          "optional" => false
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_FILES,
          "title" => "Add a file for the submission",
          "metadata" => {
          },
          "optional" => true
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_MULTI_CHOICE,
          "title" => "Choose one item",
          "metadata" => {
            "allowMultiple" => false,
            "choices" => ["First Choice", "Another Choice"]
          },
          "optional" => false
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_LINK,
          "title" => "Attach a link for the submission",
          "metadata" => {
          },
          "optional" => true
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_AUDIO,
          "title" => "Title for audio item",
          "metadata" => {
          },
          "optional" => false
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_AUDIO,
          "title" => "Title for audio item 2",
          "metadata" => {
          },
          "optional" => false
        }
      ]

      click_button "Update Target"

      expect(page).to have_text("Target updated successfully")

      dismiss_notification

      expect(
        target_2_l2.reload.assignments.first.evaluation_criteria.count
      ).to eq(0)
      expect(target_2_l2.reload.assignments.first.checklist).to eq(
        expected_checklist
      )
    end

    scenario "admin uses controls in checklist to remove, copy and move checklist items" do
      sign_in_user course_author.user,
                   referrer:
                     details_school_course_target_path(
                       course_id: course.id,
                       id: target_3_l2.id
                     )

      expect(page).to have_text(
        "What steps should the student take to complete this assignment?"
      )

      # Move checklist item 1 down
      within("div[aria-label='Controls for checklist item 1'") do
        expect(page).to have_button("Copy")
        expect(page).to have_button("Delete")
        expect(page).to_not have_button("Move Up")
        click_button "Move Down"
      end

      # Move checklist item 3 up
      within("div[aria-label='Controls for checklist item 3'") do
        expect(page).to_not have_button("Move Down")
        click_button "Move Up"
      end

      # Delete checklist item 1
      within("div[aria-label='Controls for checklist item 1'") do
        click_button "Delete"
      end

      # Copy checklist item 2 and change it's title
      within("div[aria-label='Controls for checklist item 2'") do
        click_button "Copy"
      end

      within("div[aria-label='Editor for checklist item 3'") do
        fill_in "checklist-item-3-title",
                with: "Changed title after copy",
                fill_options: {
                  clear: :backspace
                }
        check "Optional"
      end

      click_button "Update Target"
      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      expected_checklist = [
        {
          "kind" => Assignment::CHECKLIST_KIND_LINK,
          "title" => "Attach link for your submission",
          "metadata" => {
          },
          "optional" => true
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => "Write something about your submission",
          "metadata" => {
          },
          "optional" => false
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => "Changed title after copy",
          "metadata" => {
          },
          "optional" => true
        }
      ]

      expect(target_3_l2.reload.assignments.first.checklist).to eq(
        expected_checklist
      )
    end

    scenario "admin changes target from quiz target to evaluated and adds a new checklist" do
      sign_in_user course_author.user,
                   referrer:
                     details_school_course_target_path(
                       course_id: course.id,
                       id: quiz_target.id
                     )
      expect(page).to_not have_text(
        "What steps should the student take to complete this assignment?"
      )

      # Change target into an evaluated target with checklist
      within("div#evaluated") { click_button "Yes" }

      expect(page).to have_text(
        "What steps should the student take to complete this assignment?"
      )

      # Remove the default checklist item
      within("div[aria-label='Controls for checklist item 1'") do
        click_button "Delete"
      end

      expect(page).to have_text(
        "There are currently no questions for the student to submit. The assignment needs to have atleast one question."
      )

      find("button[title='Select #{evaluation_criterion.display_name}']").click

      click_button "Update Target"
      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      target = quiz_target.reload
      assignment = target.assignments.first
      expected_checklist = []

      expect(assignment.checklist).to eq(expected_checklist)
      expect(assignment.quiz).to eq(nil)
      expect(assignment.evaluation_criteria.first).to eq(evaluation_criterion)

      # Check only the graded submissions are preserved on switching to an evaluated target
      expect(target.timeline_events.count).to eq(1)
      expect(target.timeline_events.first).to eq(
        submission_for_quiz_target_with_grades
      )
      expect(
        target.timeline_events.where(
          id: submission_for_quiz_target_without_grades.id
        )
      ).to eq([])
    end

    context "when the checklist is almost at capacity" do
      let(:checklist_with_multiple_items) do
        (1..24).map do |number|
          {
            "kind" => Assignment::CHECKLIST_KIND_SHORT_TEXT,
            "title" => "Question #{number}",
            "optional" => true
          }
        end
      end

      scenario "checklist is limited to 25 items" do
        sign_in_user course_author.user,
                     referrer:
                       details_school_course_target_path(
                         course_id: course.id,
                         id: target_3_l2.id
                       )

        expect(page).to have_text(
          "What steps should the student take to complete this assignment?"
        )

        click_button "Add another question"

        expect(page).to have_text("Question cannot be empty")
        expect(page).to have_text("Maximum allowed questions is 25!")
        expect(page).not_to have_button("Add another question")
      end
    end
  end

  context "school admin modifies the target group for a target" do
    let!(:target_group_l1) { create :target_group, level: level_1 }
    let!(:target_group_l2_1) { create :target_group, level: level_2 }
    let!(:target_group_l2_2) { create :target_group, level: level_2 }
    let!(:target_group_archived) do
      create :target_group, :archived, level: level_2
    end
    let!(:target_l2_1) do
      create :target,
             :with_shared_assignment,
             target_group: target_group_l2_1,
             sort_index: 1
    end
    let!(:target_l2_2) { create :target, target_group: target_group_l2_1 }
    let!(:assignment_target_l2_2) do
      create :assignment,
             :with_default_checklist,
             target: target_l2_2,
             prerequisite_assignments: [target_l2_1.assignments.first]
    end
    let!(:target_l2_3) do
      create :target, target_group: target_group_l1, sort_index: 1
    end
    let!(:assignment_target_l2_3) do
      create :assignment,
             :with_default_checklist,
             target: target_l2_3,
             prerequisite_assignments: [target_l2_2.assignments.first]
    end

    scenario "author moves a target to another group in the same level" do
      sign_in_user school_admin.user,
                   referrer:
                     details_school_course_target_path(
                       course_id: course.id,
                       id: target_l2_2.id
                     )

      expect(page).to have_text(
        "Level #{target_l2_2.level.number}: #{target_l2_2.target_group.name}"
      )

      # archived target groups should not be listed
      fill_in "target_group", with: target_group_archived.name
      expect(page).not_to have_selector(
        :link_or_button,
        "Pick Level #{target_group_archived.level.number}: #{target_group_archived.name}"
      )

      fill_in "target_group", with: target_group_l2_2.name
      click_button "Pick Level #{target_group_l2_2.level.number}: #{target_group_l2_2.name}"

      click_button "Update Target"
      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      expect(target_l2_2.reload.sort_index).to eq(1)
      expect(target_l2_2.target_group).to eq(target_group_l2_2)
      expect(target_l2_2.assignments.first.prerequisite_assignments).to eq(
        target_l2_1.assignments
      )
    end

    scenario "author moves a target to another group on a different level" do
      sign_in_user school_admin.user,
                   referrer:
                     details_school_course_target_path(
                       course_id: course.id,
                       id: target_l2_2.id
                     )

      expect(page).to have_text(
        "Level #{target_l2_2.level.number}: #{target_l2_2.target_group.name}"
      )

      fill_in "target_group", with: target_group_l1.name
      click_button "Pick Level #{target_group_l1.level.number}: #{target_group_l1.name}"

      click_button "Update Target"
      expect(page).to have_text("Target updated successfully")
      dismiss_notification

      expect(target_l2_2.reload.sort_index).to eq(2)
      expect(target_l2_2.target_group).to eq(target_group_l1)
    end

    context "admin modifies target that currently has submissions" do
      let!(:submission_for_auto_verified_target) do
        create :timeline_event, target: target_1_l1, passed_at: 1.day.ago
      end

      scenario "admin updates target title" do
        sign_in_user school_admin.user,
                     referrer:
                       details_school_course_target_path(
                         course_id: course.id,
                         id: target_1_l1.id
                       )

        expect(page).to have_text("Title")

        fill_in "title",
                with: new_target_title,
                fill_options: {
                  clear: :backspace
                }

        click_button "Update Target"
        expect(page).to have_text("Target updated successfully")
        dismiss_notification

        expect(target_1_l1.reload.timeline_events.count).to eq(1)
      end

      scenario "admin changes target from auto-verified to evaluated" do
        sign_in_user school_admin.user,
                     referrer:
                       details_school_course_target_path(
                         course_id: course.id,
                         id: target_1_l1.id
                       )

        expect(page).to have_text("Title")

        within("div#evaluated") { click_button "Yes" }

        find(
          "button[title='Select #{evaluation_criterion.display_name}']"
        ).click

        within("div#visibility") { click_button "Live" }

        click_button "Update Target"
        expect(page).to have_text("Target updated successfully")
        dismiss_notification

        expect(target_1_l1.reload.timeline_events.count).to eq(0)
      end

      scenario "admin checks out github actions for a target" do
        sign_in_user school_admin.user,
                     referrer:
                       details_school_course_target_path(
                         course_id: course.id,
                         id: target_1_l1.id
                       )

        expect(page).to have_text("Github Actions")
        click_link "Configure Github Actions"

        expect(page).to have_text(
          "You will need to configure Github before you can use this feature"
        )
        expect(page).to have_button("Update Action", disabled: true)
      end
    end
  end

  scenario "school admin enables discussions on a target" do
    sign_in_user school_admin.user,
                 referrer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text("Title")

    expect(page).to_not have_text("Setup submission anonymity")

    within("div#discussion") { click_button "Yes" }

    expect(page).to have_text("Setup submission anonymity")

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.assignments.first.discussion).to eq(true)
    expect(target_1_l2.reload.assignments.first.allow_anonymous).to eq(false)

    click_button "Students will have an option to share their submission anonymously"

    click_button "Update Target"
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.assignments.first.allow_anonymous).to eq(true)
  end
end
