require "rails_helper"

feature "Submission Builder", js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  let(:course) { create :course }
  let(:cohort) { create :cohort, course: course }
  let(:grade_labels_for_1) do
    [
      { "grade" => 1, "label" => "Okay" },
      { "grade" => 2, "label" => "Good" },
      { "grade" => 3, "label" => "Great" },
      { "grade" => 4, "label" => "Wow" }
    ]
  end
  let!(:criterion_1) do
    create :evaluation_criterion,
           course: course,
           max_grade: 4,
           grade_labels: grade_labels_for_1
  end
  let!(:level_1) { create :level, :one, course: course }
  let!(:student) { create :student, cohort: cohort }
  let!(:target_group_l1) { create :target_group, level: level_1 }
  let!(:target) do
    create :target,
           :with_shared_assignment,
           :with_content,
           target_group: target_group_l1,
           given_role: Assignment::ROLE_TEAM,
           given_evaluation_criteria: [criterion_1]
  end
  let!(:target_assignment) { target.assignments.first }

  let!(:form_submission_target) do
    create :target,
           :with_shared_assignment,
           :with_content,
           target_group: target_group_l1,
           given_role: Assignment::ROLE_TEAM
  end

  let!(:form_submission_target_assignment) do
    form_submission_target.assignments.first
  end

  scenario "student submits a target with long text" do
    question = Faker::Lorem.sentence
    target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_LONG_TEXT,
          optional: false
        }
      ]
    )
    long_answer = Faker::Lorem.sentence

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # Filling in with a bunch of spaces should not work.
    add_markdown "   "

    expect(page).to have_button("Submit", disabled: true)

    # The user should be able to write text as description
    replace_markdown long_answer

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => question,
          "result" => long_answer,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Submissions")
    expect(page).to have_text(question)
    expect(page).to have_text(long_answer)
  end

  scenario "student submits a target with short text" do
    question = Faker::Lorem.sentence
    target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_SHORT_TEXT,
          optional: false
        }
      ]
    )
    short_answer = Faker::Lorem.words.join(" ")

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # Filling in with a bunch of spaces should not work.
    fill_in question, with: "   "

    expect(page).to have_button("Submit", disabled: true)

    # The user should be able to write text as description
    fill_in question, with: short_answer

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_SHORT_TEXT,
          "title" => question,
          "result" => short_answer,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Submissions")
    expect(page).to have_text(question)
    expect(page).to have_text(short_answer)
  end

  scenario "student submits a target with a link" do
    question = Faker::Lorem.sentence
    target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_LINK,
          optional: false
        }
      ]
    )
    link = "https://example.com?q=1"

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # Filling in with a bunch of spaces should not work.
    fill_in question, with: "   "

    expect(page).to have_button("Submit", disabled: true)

    fill_in question, with: "foobar"

    expect(page).to have_content("This doesn't look like a valid URL.")

    fill_in question, with: link

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LINK,
          "title" => question,
          "result" => link,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Submissions")
    expect(page).to have_text(question)
    expect(page).to have_text(link)
  end

  scenario "student submits a target with files" do
    question = Faker::Lorem.sentence
    target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_FILES,
          optional: false
        }
      ]
    )

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    within("div[aria-label='0-files'") do
      expect(page).to have_content(question)
      expect(page).to have_content("Choose file to upload")
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join("spec/support/uploads/faculty/human.png")
                ),
                visible: false
    expect(page).to have_text("human")

    sleep 0.1

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/minnie_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("minnie_mouse")

    sleep 0.1

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/mickey_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("mickey_mouse")

    # The attachment forms should have disappeared now.
    expect(page).not_to have_content("Choose file to upload")

    # Student can delete attached submissions
    click_button "Remove human"

    expect(page).to have_content("Choose file to upload")

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    last_submission_file_ids =
      last_submission.timeline_event_files.map { |f| f.id.to_s }
    checklist_item = last_submission.checklist.first

    expect(last_submission.timeline_event_files.last.user).to eq(student.user)
    expect(checklist_item["kind"]).to eq(Assignment::CHECKLIST_KIND_FILES)
    expect(checklist_item["title"]).to eq(question)
    expect(checklist_item["result"]).to match_array(last_submission_file_ids)
    expect(checklist_item["status"]).to eq(
      TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
    )

    expect(page).to have_text("Your Submissions")
    expect(page).to have_text(question)
    expect(page).to have_link(
      "mickey_mouse.jpg",
      href: "/timeline_event_files/#{TimelineEventFile.last.id}/download"
    )
    expect(page).to have_text("minnie_mouse")
  end

  scenario "student submits a target with an MCQ" do
    question = Faker::Lorem.sentence
    choices = Faker::Lorem.sentences(number: 4)
    target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_MULTI_CHOICE,
          optional: false,
          metadata: {
            allowMultiple: false,
            choices: choices
          }
        }
      ]
    )
    answer = choices.last

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    within("div[aria-label='0-multiChoice'") do
      expect(page).to have_content(question)
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    find("label", text: answer).click

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_MULTI_CHOICE,
          "title" => question,
          "result" => [answer],
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Submissions")
    expect(page).to have_text(question)
    expect(page).to have_text(answer)
  end

  scenario "student submits a target with long text and skips a link" do
    question_1 = Faker::Lorem.sentence
    question_2 = Faker::Lorem.sentence
    target_assignment.update!(
      checklist: [
        {
          title: question_1,
          kind: Assignment::CHECKLIST_KIND_LONG_TEXT,
          optional: false
        },
        {
          title: question_2,
          kind: Assignment::CHECKLIST_KIND_LINK,
          optional: true
        }
      ]
    )
    long_answer = Faker::Lorem.sentence

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    within("div[aria-label='0-longText'") do
      expect(page).to have_content(question_1)
    end

    within("div[aria-label='1-link'") do
      expect(page).to have_content(question_2)
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # The user should be able to write text as description
    add_markdown long_answer

    # The submit button should be enabled at this point.
    expect(page).to have_button("Submit", disabled: false)

    fill_in question_2, with: "foobar"

    expect(page).to have_content("This doesn't look like a valid URL.")

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    fill_in question_2, with: "https://example.com?q=1"

    # The submit button should be enabled at this point.
    expect(page).to have_button("Submit", disabled: false)

    fill_in question_2, with: ""

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => question_1,
          "result" => long_answer,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Submissions")
    expect(page).to have_text(question_1)
    expect(page).to have_text(long_answer)
    expect(page).not_to have_text(question_2)
  end

  scenario "student submits a target with multiple files checklist items" do
    question_1 = Faker::Lorem.sentence
    question_2 = Faker::Lorem.sentence
    target_assignment.update!(
      checklist: [
        {
          title: question_1,
          kind: Assignment::CHECKLIST_KIND_FILES,
          optional: false
        },
        {
          title: question_2,
          kind: Assignment::CHECKLIST_KIND_FILES,
          optional: false
        }
      ]
    )

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    within("div[aria-label='0-files'") do
      expect(page).to have_content(question_1)
      expect(page).to have_content("Choose file to upload")
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join("spec/support/uploads/faculty/human.png")
                ),
                visible: false
    expect(page).to have_text("human")

    sleep 0.1

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/minnie_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("minnie_mouse")

    sleep 0.1

    attach_file "attachment_file_1",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/mickey_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("mickey_mouse")

    expect(page).to have_content("Choose file to upload")

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    expect(last_submission.timeline_event_files.count).to eq(3)

    item_1_submission_file_ids =
      last_submission.timeline_event_files.first(2).map { |f| f.id.to_s }
    item_2_submission_file_ids =
      last_submission.timeline_event_files.last.id.to_s.split
    checklist_item_1 = last_submission.checklist.first
    checklist_item_2 = last_submission.checklist.last

    expect(checklist_item_1["kind"]).to eq(Assignment::CHECKLIST_KIND_FILES)
    expect(checklist_item_1["title"]).to eq(question_1)
    expect(checklist_item_1["result"]).to match_array(
      item_1_submission_file_ids
    )
    expect(checklist_item_1["status"]).to eq(
      TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
    )

    expect(checklist_item_2["kind"]).to eq(Assignment::CHECKLIST_KIND_FILES)
    expect(checklist_item_2["title"]).to eq(question_2)
    expect(checklist_item_2["result"]).to match_array(
      item_2_submission_file_ids
    )
    expect(checklist_item_2["status"]).to eq(
      TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
    )

    expect(page).to have_text("Your Submissions")
    expect(page).to have_text(question_1)
    expect(page).to have_text(question_2)

    within("div[aria-label='#{question_1}'") do
      expect(page).to have_link(
        "human.png",
        href:
          "/timeline_event_files/#{item_1_submission_file_ids.first}/download"
      )
      expect(page).to have_link(
        "minnie_mouse.jpg",
        href:
          "/timeline_event_files/#{item_1_submission_file_ids.last}/download"
      )
    end

    within("div[aria-label='#{question_2}'") do
      expect(page).to have_link(
        "mickey_mouse.jpg",
        href:
          "/timeline_event_files/#{item_2_submission_file_ids.first}/download"
      )
    end
  end

  scenario "student submits a target with audio upload item" do
    question = Faker::Lorem.sentence
    target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_AUDIO,
          optional: false
        }
      ]
    )

    sign_in_user student.user, referrer: target_path(target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Complete").click

    within("div[aria-label='0-audio'") do
      expect(page).to have_content(question)
      expect(page).to have_content("Start Recording")
      expect(page).to_not have_css("audio")

      click_on "Start Recording"
      sleep 4
      click_on "Recording"

      expect(page).to have_css("audio", count: 1)
      expect(page).to have_text("Record Again")
    end

    click_button "Submit"

    expect(page).to have_content("Your submission has been queued for review")

    last_submission = TimelineEvent.last
    submission_files = last_submission.timeline_event_files
    expect(submission_files.count).to eq(1)
    expect(submission_files.first.file.blob.content_type).to eq("audio/webm")
  end

  # Form Submission builder
  scenario "student submits a form target with default checklist" do
    sign_in_user student.user, referrer: target_path(form_submission_target)

    long_answer = Faker::Lorem.sentence

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Complete' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # Filling in with a bunch of spaces should not work.
    add_markdown "   "

    expect(page).to have_button("Submit", disabled: true)

    # The user should be able to write text as description
    replace_markdown long_answer

    click_button "Submit"

    expect(page).to have_content("Your response has been saved")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => "Write something about your submission",
          "result" => long_answer,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text("Write something about your submission")
    expect(page).to have_text(long_answer)
  end

  scenario "student submits a form target with long text" do
    question = Faker::Lorem.sentence
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_LONG_TEXT,
          optional: false
        }
      ]
    )
    long_answer = Faker::Lorem.sentence

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # Filling in with a bunch of spaces should not work.
    add_markdown "   "

    expect(page).to have_button("Submit", disabled: true)

    # The user should be able to write text as description
    replace_markdown long_answer

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => question,
          "result" => long_answer,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text(question)
    expect(page).to have_text(long_answer)
  end

  scenario "student submits a form target with short text" do
    question = Faker::Lorem.sentence
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_SHORT_TEXT,
          optional: false
        }
      ]
    )
    short_answer = Faker::Lorem.words.join(" ")

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # Filling in with a bunch of spaces should not work.
    fill_in question, with: "   "

    expect(page).to have_button("Submit", disabled: true)

    # The user should be able to write text as description
    fill_in question, with: short_answer

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_SHORT_TEXT,
          "title" => question,
          "result" => short_answer,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text(question)
    expect(page).to have_text(short_answer)
  end

  scenario "student submits a form target with a link" do
    question = Faker::Lorem.sentence
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_LINK,
          optional: false
        }
      ]
    )
    link = "https://example.com?q=1"

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # Filling in with a bunch of spaces should not work.
    fill_in question, with: "   "

    expect(page).to have_button("Submit", disabled: true)

    fill_in question, with: "foobar"

    expect(page).to have_content("This doesn't look like a valid URL.")

    fill_in question, with: link

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LINK,
          "title" => question,
          "result" => link,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text(question)
    expect(page).to have_text(link)
  end

  scenario "student submits a form target with files" do
    question = Faker::Lorem.sentence
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_FILES,
          optional: false
        }
      ]
    )

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    within("div[aria-label='0-files'") do
      expect(page).to have_content(question)
      expect(page).to have_content("Choose file to upload")
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join("spec/support/uploads/faculty/human.png")
                ),
                visible: false
    expect(page).to have_text("human")

    sleep 0.1

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/minnie_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("minnie_mouse")

    sleep 0.1

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/mickey_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("mickey_mouse")

    # The attachment forms should have disappeared now.
    expect(page).not_to have_content("Choose file to upload")

    # Student can delete attached submissions
    click_button "Remove human"

    expect(page).to have_content("Choose file to upload")

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    last_submission_file_ids =
      last_submission.timeline_event_files.map { |x| x.id.to_s }
    checklist_item = last_submission.checklist.first

    expect(checklist_item["kind"]).to eq(Assignment::CHECKLIST_KIND_FILES)
    expect(checklist_item["title"]).to eq(question)
    expect(checklist_item["result"]).to match_array(last_submission_file_ids)
    expect(checklist_item["status"]).to eq(
      TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text(question)
    expect(page).to have_link(
      "mickey_mouse.jpg",
      href: "/timeline_event_files/#{TimelineEventFile.last.id}/download"
    )
    expect(page).to have_text("minnie_mouse")
  end

  scenario "student submits a form target with an MCQ" do
    question = Faker::Lorem.sentence
    choices = Faker::Lorem.sentences(number: 4)
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_MULTI_CHOICE,
          optional: false,
          metadata: {
            allowMultiple: false,
            choices: choices
          }
        }
      ]
    )
    answer = choices.last

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    within("div[aria-label='0-multiChoice'") do
      expect(page).to have_content(question)
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    find("label", text: answer).click

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_MULTI_CHOICE,
          "title" => question,
          "result" => [answer],
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text(question)
    expect(page).to have_text(answer)
  end

  scenario "student submits a form target with long text and skips a link" do
    question_1 = Faker::Lorem.sentence
    question_2 = Faker::Lorem.sentence
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question_1,
          kind: Assignment::CHECKLIST_KIND_LONG_TEXT,
          optional: false
        },
        {
          title: question_2,
          kind: Assignment::CHECKLIST_KIND_LINK,
          optional: true
        }
      ]
    )
    long_answer = Faker::Lorem.sentence

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    within("div[aria-label='0-longText'") do
      expect(page).to have_content(question_1)
    end

    within("div[aria-label='1-link'") do
      expect(page).to have_content(question_2)
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    # The user should be able to write text as description
    add_markdown long_answer

    # The submit button should be enabled at this point.
    expect(page).to have_button("Submit", disabled: false)

    fill_in question_2, with: "foobar"

    expect(page).to have_content("This doesn't look like a valid URL.")

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    fill_in question_2, with: "https://example.com?q=1"

    # The submit button should be enabled at this point.
    expect(page).to have_button("Submit", disabled: false)

    fill_in question_2, with: ""

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq(
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => question_1,
          "result" => long_answer,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text(question_1)
    expect(page).to have_text(long_answer)
    expect(page).not_to have_text(question_2)
  end

  scenario "student submits a form target with multiple files checklist items" do
    question_1 = Faker::Lorem.sentence
    question_2 = Faker::Lorem.sentence
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question_1,
          kind: Assignment::CHECKLIST_KIND_FILES,
          optional: false
        },
        {
          title: question_2,
          kind: Assignment::CHECKLIST_KIND_FILES,
          optional: false
        }
      ]
    )

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    within("div[aria-label='0-files'") do
      expect(page).to have_content(question_1)
      expect(page).to have_content("Choose file to upload")
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button("Submit", disabled: true)

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join("spec/support/uploads/faculty/human.png")
                ),
                visible: false
    expect(page).to have_text("human")

    sleep 0.1

    attach_file "attachment_file_0",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/minnie_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("minnie_mouse")

    sleep 0.1

    attach_file "attachment_file_1",
                File.absolute_path(
                  Rails.root.join(
                    "spec/support/uploads/faculty/mickey_mouse.jpg"
                  )
                ),
                visible: false
    expect(page).to have_text("mickey_mouse")

    expect(page).to have_content("Choose file to upload")

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    expect(last_submission.timeline_event_files.count).to eq(3)

    item_1_submission_file_ids =
      last_submission.timeline_event_files.first(2).map { |f| f.id.to_s }
    item_2_submission_file_ids =
      last_submission.timeline_event_files.last.id.to_s.split
    checklist_item_1 = last_submission.checklist.first
    checklist_item_2 = last_submission.checklist.last

    expect(checklist_item_1["kind"]).to eq(Assignment::CHECKLIST_KIND_FILES)
    expect(checklist_item_1["title"]).to eq(question_1)
    expect(checklist_item_1["result"]).to match_array(
      item_1_submission_file_ids
    )
    expect(checklist_item_1["status"]).to eq(
      TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
    )

    expect(checklist_item_2["kind"]).to eq(Assignment::CHECKLIST_KIND_FILES)
    expect(checklist_item_2["title"]).to eq(question_2)
    expect(checklist_item_2["result"]).to match_array(
      item_2_submission_file_ids
    )
    expect(checklist_item_2["status"]).to eq(
      TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
    )

    expect(page).to have_text("Your Responses")
    expect(page).to have_text(question_1)
    expect(page).to have_text(question_2)

    within("div[aria-label='#{question_1}'") do
      expect(page).to have_link(
        "human.png",
        href:
          "/timeline_event_files/#{item_1_submission_file_ids.first}/download"
      )
      expect(page).to have_link(
        "minnie_mouse.jpg",
        href:
          "/timeline_event_files/#{item_1_submission_file_ids.last}/download"
      )
    end

    within("div[aria-label='#{question_2}'") do
      expect(page).to have_link(
        "mickey_mouse.jpg",
        href:
          "/timeline_event_files/#{item_2_submission_file_ids.first}/download"
      )
    end
  end

  scenario "student submits a form target with audio upload item" do
    question = Faker::Lorem.sentence
    form_submission_target_assignment.update!(
      checklist: [
        {
          title: question,
          kind: Assignment::CHECKLIST_KIND_AUDIO,
          optional: false
        }
      ]
    )

    sign_in_user student.user, referrer: target_path(form_submission_target)

    # This target should have a 'Submit Form' section.
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    within("div[aria-label='0-audio'") do
      expect(page).to have_content(question)
      expect(page).to have_content("Start Recording")
      expect(page).to_not have_css("audio")

      click_on "Start Recording"
      sleep 4
      click_on "Recording"

      expect(page).to have_css("audio", count: 1)
      expect(page).to have_text("Record Again")
    end

    sleep 0.5

    click_button "Submit"

    expect(page).to have_text("Your response has been saved")

    last_submission = TimelineEvent.last
    submission_files = last_submission.timeline_event_files
    expect(submission_files.count).to eq(1)
    expect(submission_files.first.file.blob.content_type).to eq("audio/webm")
  end
end
