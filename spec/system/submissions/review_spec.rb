require "rails_helper"

feature "Submission review overlay", js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper
  include SubmissionsHelper
  include DevelopersNotificationsHelper
  include ConfigHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, :with_cohort, school: school }
  let(:cohort) { course.cohorts.first }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:target) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:target_2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:auto_verify_target) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
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
           course: course,
           max_grade: 4,
           grade_labels: grade_labels_for_1
  end
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }

  let(:team) { create :team, cohort: cohort }
  let(:student) { create :student, cohort: cohort, team: team }
  let!(:another_student) { create :student, cohort: cohort, team: team }
  let(:coach) { create :faculty, school: school }
  let(:team_coach_user) { create :user, name: "John Doe" }
  let(:team_coach) { create :faculty, school: school, user: team_coach_user }
  let(:school_admin) { create :school_admin }

  before do
    create :faculty_cohort_enrollment, faculty: coach, cohort: cohort
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: team_coach,
           student: student

    # Set evaluation criteria on the target so that its submissions can be reviewed.
    target.assignments.first.evaluation_criteria << [
      evaluation_criterion_1,
      evaluation_criterion_2
    ]
    target_2.assignments.first.evaluation_criteria << [
      evaluation_criterion_1,
      evaluation_criterion_2
    ]
  end

  context "with a pending submission" do
    let!(:submission_pending) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target
      )
    end
    let!(:submission_pending_2) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target_2,
        reviewer_assigned_at: 1.day.ago,
        reviewer: team_coach
      )
    end
    let!(:submission_file_attachment) do
      create(:timeline_event_file, timeline_event: submission_pending)
    end

    let!(:submission_audio_attachment) do
      create(
        :timeline_event_file,
        timeline_event: submission_pending,
        file_path: "files/audio_file_sample.mp3"
      )
    end

    scenario "coach visits submission review page" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      within("div[aria-label='submissions-overlay-header']") do
        expect(page).to have_content("Submitted by #{student.name}")
        expect(page).to have_link(
          student.name,
          href: "/students/#{student.id}/report"
        )
        expect(page).to have_link(target.title, href: "/targets/#{target.id}")
        expect(page).to have_content(target.title)
        expect(page).to have_text "Assigned Coaches"

        # Hovering over the avatar should reveal the name of the assigned coach.
        page.find("svg", text: "JD").hover
        expect(page).to have_text("John Doe")
      end

      click_button "Start Review"
      expect(page).to have_content("Add Your Feedback")
      expect(page).to have_content("Grade Card")
      expect(page).to have_content(evaluation_criterion_1.name)
      expect(page).to have_content(evaluation_criterion_2.name)
      expect(page).to have_button("Save grades", disabled: true)
      click_button "Remove assignment"
      dismiss_notification
      expect(page).to have_button("Start Review")
    end

    scenario "coach visits an assigned submission" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_pending_2)
      expect(page).to have_text(team_coach.name)
      expect(page).not_to have_text("Start Review")
      expect(page).to have_button("Remove assignment")
    end

    scenario "coach takes over an assigned submission" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending_2)
      expect(page).to have_text(team_coach.name)
      expect(page).not_to have_text("Start Review")
      click_button "Yes, Assign Me"
      dismiss_notification
      expect(page).to have_text(coach.name)
      expect(page).to have_button("Remove assignment")
    end

    scenario "coach evaluates a pending submission and gives a feedback" do
      notification_service = prepare_developers_notification

      sign_in_user coach.user, referrer: review_course_path(course)

      expect(page).to have_content(target.title)
      expect(page).to have_content(target_2.title)

      find("a[data-submission-id='#{submission_pending.id}']").click
      click_button "Start Review"

      expect(page).to have_content("Grade Card")
      expect(submission_pending.reload.reviewer).to eq(coach)
      expect(submission_pending.reviewer_assigned_at).not_to eq(nil)
      feedback = Faker::Markdown.sandwich(sentences: 6)
      add_markdown(feedback)
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) do
        expect(page).to have_selector(
          ".course-review-editor__grade-pill",
          count: 4
        )
        find("button[title='Okay']").click
      end

      # status should be Pending Review as the target is not graded completely
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Pending Review")
      end
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) do
        expect(page).to have_selector(
          ".course-review-editor__grade-pill",
          count: 3
        )
        find("button[title='Okay']").click
      end

      # the status should be Completed
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Completed")
      end

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }

      # the status should still be Completed
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Completed")
      end

      click_button "Save grades & send feedback"

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
      end

      student = submission_pending.students.first
      open_email(student.user.email)
      expect(current_email).to have_content("grades")

      expect(page).to have_button("Undo Grading")

      submission = submission_pending.reload
      expect(submission.reviewer).to eq(nil)
      expect(submission.reviewer_assigned_at).to eq(nil)
      expect(submission.evaluator_id).to eq(coach.id)
      expect(submission.passed_at).not_to eq(nil)
      expect(submission.evaluated_at).not_to eq(nil)
      expect(submission.startup_feedback.count).to eq(1)
      expect(submission.startup_feedback.last.feedback).to eq(feedback)
      expect(submission.timeline_event_grades.pluck(:grade)).to contain_exactly(
        1,
        2
      )

      # the submission must be removed from the pending list

      find("button[aria-label='submissions-overlay-close']").click
      click_link "Pending"
      expect(page).to have_text(submission_pending_2.target.title)
      expect(page).to_not have_text(submission.target.title)

      expect_published(
        notification_service,
        course,
        :submission_graded,
        coach.user,
        submission
      )
    end

    scenario "coach rejects a pending submission with a feedback" do
      notification_service = prepare_developers_notification

      sign_in_user coach.user, referrer: review_course_path(course)

      expect(page).to have_content(target.title)
      expect(page).to have_content(target_2.title)

      find("a[data-submission-id='#{submission_pending.id}']").click
      click_button "Start Review"

      expect(page).to have_content("Grade Card")
      expect(submission_pending.reload.reviewer).to eq(coach)
      expect(submission_pending.reviewer_assigned_at).not_to eq(nil)
      feedback = Faker::Markdown.sandwich(sentences: 6)
      add_markdown(feedback)

      within("div#is_acceptable") { click_button "No" }
      # the status should be Rejected before clicking Reject button
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Rejected")
      end

      click_button "Reject submission & send feedback"

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Rejected")
      end

      open_email submission_pending.students.first.user.email
      expect(current_email).to have_content("rejected")

      student = submission_pending.students.first
      open_email(student.user.email)
      expect(current_email).to have_content("rejected")

      expect(page).to have_button("Undo Rejection")

      submission = submission_pending.reload
      expect(submission.reviewer).to eq(nil)
      expect(submission.reviewer_assigned_at).to eq(nil)
      expect(submission.evaluator_id).to eq(coach.id)
      expect(submission.passed_at).to eq(nil)
      expect(submission.evaluated_at).not_to eq(nil)
      expect(submission.startup_feedback.count).to eq(1)
      expect(submission.startup_feedback.last.feedback).to eq(feedback)
      expect(submission.timeline_event_grades.pluck(:grade)).to eq([])

      # the submission must be removed from the pending list

      find("button[aria-label='submissions-overlay-close']").click
      click_link "Pending"
      expect(page).to have_text(submission_pending_2.target.title)
      expect(page).to_not have_text(submission.target.title)

      expect_published(
        notification_service,
        course,
        :submission_graded,
        coach.user,
        submission
      )
    end

    scenario "coach undo a rejection" do
      sign_in_user coach.user, referrer: review_course_path(course)

      find("a[data-submission-id='#{submission_pending.id}']").click
      click_button "Start Review"
      within("div#is_acceptable") { click_button "No" }
      click_button "Reject Submission"

      accept_confirm { click_button "Undo Rejection" }

      expect(page).to have_text("Start Review")

      submission = submission_pending.reload
      expect(submission.evaluator_id).to eq(nil)
      expect(submission.passed_at).to eq(nil)
      expect(submission.evaluated_at).to eq(nil)
      expect(submission.timeline_event_grades).to eq([])
    end

    scenario "coaches can view and edit the review checklist without assigning themselves" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      expect(target.review_checklist).to eq([])

      expect(page).to have_content("Create Review Checklist")
      click_button "Create Review Checklist"

      expect(page).to have_content("Save Checklist")
      click_button "Save Checklist"
      dismiss_notification
      within("div[data-checklist-item='0']") do
        expect(page).to have_content("Default checklist")

        within("div[data-result-item='0']") do
          expect(page).to have_content("Yes")
        end

        within("div[data-result-item='1']") do
          expect(page).to have_content("No")
          find("label", text: "No").click
        end
      end

      expect(page).not_to have_button("Generate Feedback")
      expect(page).to have_content("Edit Checklist")
      expect(page).to have_content("Back to Review")
      click_button "Back to Review"
      expect(page).to have_content("Start Review")
      expect(page).to have_content("Show Review Checklist")
    end

    scenario "coach generates feedback from review checklist" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      # Checklist item 1
      checklist_title_1 = Faker::Lorem.sentence
      c1_result_0_title = Faker::Lorem.sentence
      c1_result_0_feedback = Faker::Markdown.sandwich(sentences: 3)
      c1_result_1_title = Faker::Lorem.sentence
      c1_result_1_feedback = Faker::Markdown.sandwich(sentences: 3)

      # Checklist item 2
      checklist_title_2 = Faker::Lorem.sentence
      c2_result_0_title = Faker::Lorem.sentence
      c2_result_0_feedback = Faker::Markdown.sandwich(sentences: 3)
      c2_result_1_title = Faker::Lorem.sentence
      c2_result_1_feedback = Faker::Markdown.sandwich(sentences: 3)

      # Checklist item 3
      checklist_title_3 = "Empty checklist item"
      c3_result_0_title = "Empty checklist result 1"
      c3_result_0_feedback = nil
      c3_result_1_title = "Empty checklist result 2"
      c3_result_1_feedback = nil

      expect(target.review_checklist).to eq([])
      click_button "Start Review"

      expect(page).to have_text("Add Your Feedback")

      click_button "Create Review Checklist"

      within("div[data-checklist-item='0']") do
        fill_in "checklist_0_title", with: checklist_title_1
        fill_in "result_00_title", with: c1_result_0_title
        fill_in "result_00_feedback", with: c1_result_0_feedback

        fill_in "result_01_title", with: c1_result_1_title
        fill_in "result_01_feedback", with: c1_result_1_feedback
      end

      click_button "Add Checklist Item"

      within("div[data-checklist-item='1']") do
        fill_in "checklist_1_title", with: checklist_title_2
        fill_in "result_10_title", with: c2_result_0_title
        fill_in "result_10_feedback", with: c2_result_0_feedback
        click_button "Add Result"
        fill_in "result_11_title", with: c2_result_1_title
        fill_in "result_11_feedback", with: c2_result_1_feedback
      end

      click_button "Add Checklist Item"

      within("div[data-checklist-item='2']") do
        fill_in "checklist_2_title", with: checklist_title_3
        fill_in "result_20_title", with: c3_result_0_title
        fill_in "result_20_feedback", with: c3_result_0_feedback
        click_button "Add Result"
        fill_in "result_21_title", with: c3_result_1_title
        fill_in "result_21_feedback", with: c3_result_1_feedback
      end

      click_button "Save Checklist"

      expect(page).to have_content("Edit Checklist")

      expect(target.reload.review_checklist).not_to eq([])

      # Reload Page
      visit review_timeline_event_path(submission_pending)

      click_button "Show Review Checklist"

      within("div[data-checklist-item='0']") do
        expect(page).to have_content(checklist_title_1)

        within("div[data-result-item='0']") do
          expect(page).to have_content(c1_result_0_title)
          find("label", text: c1_result_0_title).click
        end

        within("div[data-result-item='1']") do
          expect(page).to have_content(c1_result_1_title)
          find("label", text: c1_result_1_title).click
        end
      end

      within("div[data-checklist-item='1']") do
        expect(page).to have_content(checklist_title_2)
        within("div[data-result-item='0']") do
          expect(page).to have_content(c2_result_0_title)
          find("label", text: c2_result_0_title).click
        end

        within("div[data-result-item='1']") do
          expect(page).to have_content(c2_result_1_title)
          find("label", text: c2_result_1_title).click
        end
      end

      # Add Additional Feedback for empty checklist result item
      checkbox_21 = find(:css, "[id$='review-checkbox-21']")
      expect(page).not_to have_button("Add Additional Feedback")
      checkbox_21.set(true)
      expect(checkbox_21).to be_checked
      expect(page).to have_button("Add Additional Feedback")
      click_button "Add Additional Feedback"
      expect(page).to have_field("checklist_2_result_1_text_area", with: "")
      find(
        "div[data-checklist-item='2']"
      ).fill_in "checklist_2_result_1_text_area",
                with: "Additional Feedback for empty checklist result item 2"
      checkbox_21.set(false)
      expect(page).not_to have_button("Add Additional Feedback")

      checkbox_20 = find(:css, "[id$='review-checkbox-20']")
      expect(page).not_to have_button("Add Additional Feedback")
      checkbox_20.set(true)
      expect(checkbox_20).to be_checked
      expect(page).to have_button("Add Additional Feedback")
      click_button "Add Additional Feedback"
      expect(page).to have_field("checklist_2_result_0_text_area", with: "")
      find(
        "div[data-checklist-item='2']"
      ).fill_in "checklist_2_result_0_text_area",
                with: "Additional Feedback for empty checklist result item"

      click_button "Generate Feedback"

      expect(page).not_to have_button("Generate Feedback")
      expect(page).to have_text("Feedback generated from review checklist")

      within("div[aria-label='feedback']") do
        expect(page).to have_content(c1_result_0_feedback)
        expect(page).to have_content(c1_result_1_feedback)
        expect(page).to have_content(c2_result_0_feedback)
        expect(page).to have_content(
          "Additional Feedback for empty checklist result item"
        )
      end

      click_button "Show Review Checklist"
      click_button "Edit Checklist"

      within("div[data-checklist-item='1']") do
        within("div[data-result-item='0']") do
          find("button[title='Remove checklist result']").click
        end
      end

      within("div[data-checklist-item='2']") do
        find("button[title='Remove checklist item']").click
      end

      within("div[data-checklist-item='1']") do
        find("button[title='Remove checklist item']").click
      end

      within("div[data-checklist-item='0']") do
        find("button[title='Remove checklist item']").click
      end

      click_button "Save Checklist"

      click_button "Create Review Checklist"
      expect(target.reload.review_checklist).to eq([])
    end

    scenario "coach changes the order of review checklist" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      # Checklist item 1
      checklist_title_1 = "Checklist item one"
      c1_result_0_title = Faker::Lorem.sentence
      c1_result_0_feedback = Faker::Markdown.sandwich(sentences: 3)
      c1_result_1_title = Faker::Lorem.sentence
      c1_result_1_feedback = Faker::Markdown.sandwich(sentences: 3)

      # Checklist item 2
      checklist_title_2 = "Checklist item two"
      c2_result_0_title = Faker::Lorem.sentence
      c2_result_0_feedback = Faker::Markdown.sandwich(sentences: 3)
      c2_result_1_title = Faker::Lorem.sentence
      c2_result_1_feedback = Faker::Markdown.sandwich(sentences: 3)

      # Checklist item 3
      checklist_title_3 = "Checklist item three"
      c3_result_0_title = Faker::Lorem.sentence
      c3_result_0_feedback = Faker::Markdown.sandwich(sentences: 3)
      c3_result_1_title = Faker::Lorem.sentence
      c3_result_1_feedback = Faker::Markdown.sandwich(sentences: 3)

      expect(target.review_checklist).to eq([])
      click_button "Start Review"

      expect(page).to have_text("Add Your Feedback")
      click_button "Create Review Checklist"

      within("div[data-checklist-item='0']") do
        fill_in "checklist_0_title", with: checklist_title_1
        fill_in "result_00_title", with: c1_result_0_title
        fill_in "result_00_feedback", with: c1_result_0_feedback
        fill_in "result_01_title", with: c1_result_1_title
        fill_in "result_01_feedback", with: c1_result_1_feedback
      end

      click_button "Add Checklist Item"

      within("div[data-checklist-item='1']") do
        fill_in "checklist_1_title", with: checklist_title_2
        fill_in "result_10_title", with: c2_result_0_title
        fill_in "result_10_feedback", with: c2_result_0_feedback
        click_button "Add Result"
        fill_in "result_11_title", with: c2_result_1_title
        fill_in "result_11_feedback", with: c2_result_1_feedback
      end

      click_button "Add Checklist Item"

      within("div[data-checklist-item='2']") do
        fill_in "checklist_2_title", with: checklist_title_3
        fill_in "result_20_title", with: c3_result_0_title
        fill_in "result_20_feedback", with: c3_result_0_feedback
        click_button "Add Result"
        fill_in "result_21_title", with: c3_result_1_title
        fill_in "result_21_feedback", with: c3_result_1_feedback
      end

      click_button "Save Checklist"

      expect(page).to have_content("Edit Checklist")

      expect(target.reload.review_checklist).not_to eq([])

      # Reload Page
      visit review_timeline_event_path(submission_pending)

      click_button "Show Review Checklist"
      click_button "Edit Checklist"

      # The first checklist item should only have the "move down" button.
      within("div[data-checklist-item='0']") do
        expect(page).to_not have_button("Move Up checklist item")
        find("button[title='Move Down checklist item']")
      end

      # Checklist item in the middle should have both buttons.
      within("div[data-checklist-item='1']") do
        find("button[title='Move Up checklist item']")
        find("button[title='Move Down checklist item']")
      end

      #The last checklist item should only have the "move up" button.
      within("div[data-checklist-item='2']") do
        expect(page).to_not have_button("Move Down checklist item")
        find("button[title='Move Up checklist item']")
      end

      # The second checklist item, moved up
      within("div[data-checklist-item='1']") do
        find("button[title='Move Up checklist item']").click
      end

      # The first checklist item, should have the content as checklist_item_2 and should loose the "move up button"
      within("div[data-checklist-item='0']") do
        expect(page).to_not have_button("Move Up checklist item")
        find("button[title='Move Down checklist item']")
        expect(
          find("input", id: "checklist_0_title").value
        ).to eq checklist_title_2
        within("div[data-result-item='0']") do
          expect(
            find("input", id: "result_00_title").value
          ).to eq c2_result_0_title
        end
        within("div[data-result-item='1']") do
          expect(
            find("input", id: "result_01_title").value
          ).to eq c2_result_1_title
        end
      end

      # The second checklist item, moved down
      within("div[data-checklist-item='1']") do
        find("button[title='Move Down checklist item']").click
      end

      # The middle checklist item, should have the content as checklist_item_3 and should have the "move up & down button"
      within("div[data-checklist-item='1']") do
        find("button[title='Move Up checklist item']")
        find("button[title='Move Down checklist item']")
        expect(
          find("input", id: "checklist_1_title").value
        ).to eq checklist_title_3
        within("div[data-result-item='0']") do
          expect(
            find("input", id: "result_10_title").value
          ).to eq c3_result_0_title
        end
        within("div[data-result-item='1']") do
          expect(
            find("input", id: "result_11_title").value
          ).to eq c3_result_1_title
        end
      end

      # Results iniside checklist item move up & move down
      within("div[data-checklist-item='1']") do
        within("div[data-result-item='0']") do
          expect(page).to_not have_button("Move Up checklist result")
          find("button[title='Move Down checklist result']").click
          expect(
            find("input", id: "result_10_title").value
          ).to eq c3_result_1_title
        end
        within("div[data-result-item='1']") do
          expect(page).to_not have_button("Move Down checklist result")
          find("button[title='Move Up checklist result']").click
          expect(
            find("input", id: "result_11_title").value
          ).to eq c3_result_1_title
        end
      end

      click_button "Save Checklist"

      expect(page).to have_content("Edit Checklist")

      expect(target.reload.review_checklist).not_to eq([])

      # Reload Page
      visit review_timeline_event_path(submission_pending)

      click_button "Show Review Checklist"

      within("div[data-checklist-item='0']") do
        expect(page).to have_content(checklist_title_2)

        within("div[data-result-item='0']") do
          expect(page).to have_content(c2_result_0_title)
          find("label", text: c2_result_0_title).click
        end

        within("div[data-result-item='1']") do
          expect(page).to have_content(c2_result_1_title)
          find("label", text: c2_result_1_title).click
        end
      end

      within("div[data-checklist-item='1']") do
        expect(page).to have_content(checklist_title_3)

        within("div[data-result-item='0']") do
          expect(page).to have_content(c3_result_0_title)
          find("label", text: c3_result_0_title).click
        end

        within("div[data-result-item='1']") do
          expect(page).to have_content(c3_result_1_title)
          find("label", text: c3_result_1_title).click
        end
      end

      within("div[data-checklist-item='2']") do
        expect(page).to have_content(checklist_title_1)

        within("div[data-result-item='0']") do
          expect(page).to have_content(c1_result_0_title)
          find("label", text: c1_result_0_title).click
        end

        within("div[data-result-item='1']") do
          expect(page).to have_content(c1_result_1_title)
          find("label", text: c1_result_1_title).click
        end
      end
    end

    scenario "coach evaluates a pending submission and mark a checklist as incorrect" do
      question_1 = Faker::Lorem.sentence
      question_2 = Faker::Lorem.sentence
      question_3 = Faker::Lorem.sentence
      question_4 = Faker::Lorem.sentence
      question_5 = Faker::Lorem.sentence
      question_6 = Faker::Lorem.sentence
      answer_1 = Faker::Lorem.sentence
      answer_2 = "https://example.org/invalidLink"
      answer_3 = Faker::Lorem.sentence
      answer_4 = Faker::Lorem.sentence
      answer_5 = [submission_file_attachment.id.to_s]
      answer_6 = submission_audio_attachment.id.to_s
      submission_checklist_long_text = {
        "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
        "title" => question_1,
        "result" => answer_1,
        "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
      }
      submission_checklist_link = {
        "kind" => Assignment::CHECKLIST_KIND_LINK,
        "title" => question_2,
        "result" => answer_2,
        "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
      }
      submission_checklist_choice = {
        "kind" => Assignment::CHECKLIST_KIND_MULTI_CHOICE,
        "title" => question_3,
        "result" => [answer_3],
        "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
      }
      submission_checklist_short_text = {
        "kind" => Assignment::CHECKLIST_KIND_SHORT_TEXT,
        "title" => question_4,
        "result" => answer_4,
        "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
      }
      submission_checklist_files = {
        "kind" => Assignment::CHECKLIST_KIND_FILES,
        "title" => question_5,
        "result" => answer_5,
        "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
      }
      submission_checklist_audio = {
        "kind" => Assignment::CHECKLIST_KIND_AUDIO,
        "title" => question_6,
        "result" => answer_6,
        "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
      }
      submission_checklist = [
        submission_checklist_long_text,
        submission_checklist_link,
        submission_checklist_choice,
        submission_checklist_short_text,
        submission_checklist_files,
        submission_checklist_audio
      ]
      submission_pending.update!(checklist: submission_checklist)

      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)
      click_button "Start Review"
      within(
        "div[aria-label='#{submission_pending.checklist.first["title"]}']"
      ) do
        expect(page).to have_content(question_1)
        expect(page).to have_content(answer_1)
      end

      within(
        "div[aria-label='#{submission_pending.checklist.second["title"]}']"
      ) do
        expect(page).to have_content(question_2)
        expect(page).to have_content(answer_2)
        click_button "Mark as incorrect"
        expect(page).to have_content("Mark as correct")
      end

      within(
        "div[aria-label='#{submission_pending.checklist.third["title"]}']"
      ) do
        expect(page).to have_content(question_3)
        expect(page).to have_content(answer_3)
        click_button "Mark as incorrect"
        expect(page).to have_content("Mark as correct")
      end

      within("div[aria-label='#{submission_pending.checklist[5]["title"]}']") do
        expect(page).to have_content(question_6)
        click_button "Mark as incorrect"
        expect(page).to have_content("Mark as correct")
      end

      expect(page).to have_content("Grade Card")

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }

      # status should be Pending Review as the target is not graded completely
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Pending Review")
      end
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }

      # the status should be completed
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Completed")
      end

      click_button "Save grades"

      # the status should be completed
      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
      end

      expect(submission_pending.reload.evaluated_at).to_not eq(nil)

      within(
        "div[aria-label='#{submission_pending.checklist.second["title"]}']"
      ) { expect(page).to have_content("Incorrect") }

      new_checklist = [
        submission_checklist_long_text,
        {
          "kind" => Assignment::CHECKLIST_KIND_LINK,
          "title" => question_2,
          "result" => answer_2,
          "status" => TimelineEvent::CHECKLIST_STATUS_FAILED
        },
        {
          "kind" => Assignment::CHECKLIST_KIND_MULTI_CHOICE,
          "title" => question_3,
          "result" => [answer_3],
          "status" => TimelineEvent::CHECKLIST_STATUS_FAILED
        },
        submission_checklist_short_text,
        submission_checklist_files,
        {
          "kind" => Assignment::CHECKLIST_KIND_AUDIO,
          "title" => question_6,
          "result" => answer_6,
          "status" => TimelineEvent::CHECKLIST_STATUS_FAILED
        }
      ]

      expect(submission_pending.reload.checklist).to eq(new_checklist)

      # Reload page
      visit review_timeline_event_path(submission_pending)

      within(
        "div[aria-label='#{submission_pending.checklist.first["title"]}']"
      ) { expect(page).to have_content(answer_1) }

      within(
        "div[aria-label='#{submission_pending.checklist.second["title"]}']"
      ) do
        expect(page).to have_content(question_2)
        expect(page).to have_content(answer_2)
        expect(page).to have_content("Incorrect")
      end

      within(
        "div[aria-label='#{submission_pending.checklist.third["title"]}']"
      ) do
        expect(page).to have_content(question_3)
        expect(page).to have_content(answer_3)
        expect(page).to have_content("Incorrect")
      end

      within(
        "div[aria-label='#{submission_pending.checklist.last["title"]}']"
      ) { expect(page).to have_content("Incorrect") }

      accept_confirm { click_button("Undo Grading") }
      click_button "Start Review"

      expect(page).to have_text("Add Your Feedback")
      expect(submission_pending.reload.checklist).to eq(submission_checklist)
    end

    scenario "coach evaluates a pending submission without giving a feedback" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button "Start Review"
      expect(page).to have_content("Grade Card")

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }

      # status should be pending review as the target is not graded completely
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Pending Review")
      end
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }

      # the status should be completed
      within("div[aria-label='submission-leftpane-status']") do
        expect(page).to have_text("Completed")
      end

      click_button "Save grades"

      # the status should be completed
      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
      end

      expect(page).to have_button("Undo Grading")

      submission = submission_pending.reload
      expect(submission.evaluator_id).to eq(coach.id)
      expect(submission.passed_at).not_to eq(nil)
      expect(submission.evaluated_at).not_to eq(nil)
      expect(submission.startup_feedback.count).to eq(0)
      expect(submission.timeline_event_grades.pluck(:grade)).to eq([2, 2])
    end

    scenario "student tries to access the submission review page" do
      sign_in_user student.user,
                   referrer: review_timeline_event_path(submission_pending)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end

    scenario "school admin can view the submission" do
      sign_in_user school_admin.user,
                   referrer: review_timeline_event_path(submission_pending)

      # Admin can access the page, but cannot review the submission.

      expect(page).to have_text("Submission #1")

      expect(page).to have_text(
        "You cannot review this submission as you're not assigned to this cohort as a coach."
      )

      expect(page).to have_button("Save grades", disabled: true)
      expect(page).to have_button("Create Review Checklist", disabled: true)
      expect(page).to have_selector(
        'textarea[aria-label="Markdown editor"]:disabled'
      )
    end

    scenario "school admin cannot take over a assigned submission" do
      sign_in_user school_admin.user,
                   referrer: review_timeline_event_path(submission_pending_2)

      expect(page).to have_text(
        "You cannot review this submission as you're not assigned to this cohort as a coach."
      )

      expect(page).not_to have_button("Yes, Assign Me")
    end

    scenario "coach is warned when a student has dropped out" do
      student.update!(dropped_out_at: 1.day.ago)

      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      expect(page).to have_text(
        "This submission is from a student whose access to the course has ended, or has dropped out."
      )
    end

    scenario "coach is warned when a student's access to course has ended" do
      cohort.update!(ends_at: 1.day.ago)

      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      expect(page).to have_text(
        "This submission is from a student whose access to the course has ended, or has dropped out."
      )
    end

    context "when submission is from students who are now in different teams" do
      let(:another_team) { create :team, cohort: cohort }
      let(:another_student) do
        create :student,
               team: another_team,
               cohort: cohort,
               dropped_out_at: 1.day.ago
      end

      before { submission_pending.students << another_student }

      scenario "coach is warned when one student in the submission is inactive" do
        sign_in_user coach.user,
                     referrer: review_timeline_event_path(submission_pending)

        expect(page).to have_text(
          "This submission is linked to one or more students whose access to the course has ended, or have dropped out."
        )
      end
    end

    scenario "coach leaves a note about a student" do
      note = Faker::Lorem.sentence

      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_pending)
      click_button "Start Review"

      click_button "Write a Note"
      add_markdown note, id: "note-for-submission-#{submission_pending.id}"

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }

      click_button "Save grades"

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
      end

      new_notes = CoachNote.where(note: note)

      expect(new_notes.count).to eq(1)
      expect(new_notes.first.student_id).to eq(student.id)
    end

    scenario "coach leaves a note for a team submission" do
      another_student = team.students.where.not(id: student).first
      submission_pending.students << another_student
      note = Faker::Lorem.sentence

      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button "Start Review"

      click_button "Write a Note"
      add_markdown note, id: "note-for-submission-#{submission_pending.id}"

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }

      click_button "Save grades"

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
      end

      new_notes = CoachNote.where(note: note)

      expect(new_notes.reload.count).to eq(2)
      expect(new_notes.pluck(:student_id)).to contain_exactly(
        student.id,
        another_student.id
      )
    end

    scenario "coach opens the overlay for a submission after its status has changed in the DB" do
      # Opening the overlay should reload data on index if it's different.
      sign_in_user coach.user, referrer: review_course_path(course)
      click_link "Pending"

      expect(page).to have_text(target.title)
      expect(page).to have_text(target_2.title)

      # Review the submission from the backend.
      submission_pending.update(
        passed_at: Time.zone.now,
        evaluated_at: Time.zone.now,
        evaluator: coach
      )
      grade_submission(
        submission_pending,
        SubmissionsHelper::SUBMISSION_PASS,
        target.assignments.first
      )

      # Open the overlay.
      find("a[data-submission-id='#{submission_pending.id}']").click

      # It should show Completed.
      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
      end

      find("button[aria-label='submissions-overlay-close']").click

      # Closing the overlay should show that the item has been removed from the pending list.
      expect(page).not_to have_text(target.title)
      expect(page).to have_text(target_2.title) # The second submission should still be there.

      # The submission should be visible in the Pending list.
      click_link "Reviewed"

      # The submission should show up in the Reviewed list.
      expect(page).to have_text(target.title)

      # Undo the grading of the submission from the backend.
      submission_pending.timeline_event_grades.destroy_all
      submission_pending.update(
        passed_at: nil,
        evaluated_at: nil,
        evaluator: nil
      )

      find("a[data-submission-id='#{submission_pending.id}']").click

      # The overlay should show pending review status.
      expect(page).to have_text("Start Review")

      find("button[aria-label='submissions-overlay-close']").click

      # Closing the overlay should show that the item has been removed from the reviewed list.
      expect(page).not_to have_text(target.title)
    end
  end

  context "when coach cycles through pending submissions" do
    let!(:submission_pending_3) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target_2,
        reviewer_assigned_at: 1.day.ago,
        reviewer: team_coach
      )
    end
    let!(:submission_pending_4) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target_2,
        reviewer_assigned_at: 1.day.ago,
        reviewer: team_coach
      )
    end
    let!(:submission_pending_5) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target_2,
        reviewer_assigned_at: 1.day.ago,
        reviewer: team_coach,
        created_at: 2.days.ago
      )
    end
    scenario "coach grades and cylces through pending submissions using next button",
             js: true do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_pending_3)

      expect(page).to_not have_link("Next")

      expect(page).to have_text(submission_pending_3.title)
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }

      click_button "Save grades"

      click_link "Next"

      expect(page).to have_text(submission_pending_5.title)
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }

      click_button "Save grades"

      click_link "Next"

      expect(page).to have_text(submission_pending_4.title)
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) { find("button[title='Good']").click }
      click_button "Save grades"

      expect(page).to have_text(
        "This submission has been graded, and there are no more submissions awaiting review."
      )
    end
  end

  context "when the course has inactive students" do
    let(:ended_cohort) { create :cohort, ends_at: 1.day.ago }
    let(:inactive_student_1) { create :student, cohort: ended_cohort }
    let(:inactive_student_2) { create :student, cohort: ended_cohort }

    let!(:pending_submission_one_from_inactive_students) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        created_at: 5.days.ago,
        owners: [inactive_student_1, inactive_student_2],
        target: target
      )
    end

    let!(:pending_submission_two_from_inactive_students) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        created_at: 1.hour.ago,
        owners: [inactive_student_1, inactive_student_2],
        target: target
      )
    end

    let!(:reviewed_submission_from_inactive_students) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [inactive_student_1, inactive_student_2],
        target: target,
        evaluator_id: coach.id,
        created_at: 5.days.ago,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end
    before do
      create(
        :timeline_event_grade,
        timeline_event: reviewed_submission_from_inactive_students,
        evaluation_criterion: evaluation_criterion_1,
        grade: 4
      )

      create(:faculty_cohort_enrollment, faculty: coach, cohort: ended_cohort)
    end

    around do |example|
      with_secret(inactive_submission_review_allowed_days: 1) { example.run }
    end

    scenario "coach visits pending submission page of inactive student after submission review allowed time has elapsed" do
      sign_in_user coach.user,
                   referrer:
                     review_timeline_event_path(
                       pending_submission_one_from_inactive_students
                     )
      expect(page).not_to have_text("You can review the submission until")
      expect(page).to have_button("Create Review Checklist", disabled: true)
      expect(page).to have_button("Write a Note", disabled: true)
      expect(page).to have_button("Save grades", disabled: true)
    end

    scenario "coach visits pending submission page of inactive student within submission review allowed time" do
      sign_in_user coach.user,
                   referrer:
                     review_timeline_event_path(
                       pending_submission_two_from_inactive_students
                     )

      click_button "Start Review"

      expect(page).to have_content("You can review the submission until")
      expect(page).to have_content("Add Your Feedback")
      add_markdown("Some feedback about the submission.")
      expect(page).to have_content("Grade Card")
      expect(page).to have_content(evaluation_criterion_1.name)
      expect(page).to have_content(evaluation_criterion_2.name)
      expect(page).to have_button("Save grades", disabled: true)
      click_button "Remove assignment"
      expect(page).to have_button("Start Review")
    end

    scenario "coach visits reviewed submission page" do
      sign_in_user coach.user,
                   referrer:
                     review_timeline_event_path(
                       reviewed_submission_from_inactive_students
                     )

      expect(page).to have_button("Undo Grading", disabled: true)

      expect(page).to have_button("Add feedback", disabled: true)
    end
  end
  context "with a reviewed submission" do
    let!(:submission_reviewed) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team.students,
        target: target,
        evaluator_id: coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:timeline_event_grade) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed,
        evaluation_criterion: evaluation_criterion_1,
        grade: 4
      )
    end

    scenario "coach visits submission review page" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_reviewed)

      within("div[aria-label='submissions-overlay-header']") do
        expect(page).to have_content("Submitted by")

        # Each name should be linked to the report page.
        team.students.each do |student|
          expect(page).to have_link(
            student.name,
            href: "/students/#{student.id}/report"
          )
        end

        expect(page).to have_link(target.title, href: "/targets/#{target.id}")
      end

      expect(page).to have_content("Submission #1")
      expect(page).to have_content("Completed")

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
        expect(page).to have_text("Evaluated By")
        expect(page).to have_text(coach.name)
      end

      expect(page).to have_button("Undo Grading")

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) do
        expect(page).to have_text(evaluation_criterion_1.name)
        expect(page).to have_text(
          "#{timeline_event_grade.grade}/#{evaluation_criterion_1.max_grade}"
        )
      end

      expect(page).to have_button("Add feedback")
    end

    scenario "coach add his feedback" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_reviewed)

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
        expect(page).to have_text("Evaluated By")
        expect(page).to have_text(coach.name)
      end

      expect(page).to have_button("Undo Grading")

      expect(page).to have_button("Add feedback")

      click_button "Add feedback"

      expect(page).not_to have_button("Add feedback")
      expect(page).to have_button("Share Feedback", disabled: true)

      feedback = Faker::Markdown.sandwich(sentences: 6)
      add_markdown(feedback)
      click_button "Share Feedback"

      expect(page).to have_text("Your feedback will be e-mailed to the student")

      dismiss_notification

      expect(page).to have_button("Add another feedback")

      within("div[data-title='feedback-section']") do
        expect(page).to have_text(coach.name)
      end

      submission = submission_reviewed.reload
      expect(submission.startup_feedback.count).to eq(1)
      expect(submission.startup_feedback.last.feedback).to eq(feedback)
    end

    scenario "school admin cannot add feedback or undo grading on a previously reviewed submission" do
      sign_in_user school_admin.user,
                   referrer: review_timeline_event_path(submission_reviewed)

      expect(page).to have_text("Submission #1")

      expect(page).to have_text(
        "You cannot review this submission as you're not assigned to this cohort as a coach."
      )

      expect(page).to have_button("Add feedback", disabled: true)
      expect(page).to have_button("Undo Grading", disabled: true)
    end

    scenario "coach can undo grading" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_reviewed)

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
        expect(page).to have_text("Evaluated By")
        expect(page).to have_text(coach.name)
      end

      accept_confirm { click_button "Undo Grading" }

      expect(page).to have_text("Start Review")

      submission = submission_reviewed.reload
      expect(submission.evaluator_id).to eq(nil)
      expect(submission.passed_at).to eq(nil)
      expect(submission.evaluated_at).to eq(nil)
      expect(submission.timeline_event_grades).to eq([])
    end

    context "with two reviewed submissions" do
      let!(:submission_reviewed_old) do
        create(
          :timeline_event,
          :with_owners,
          owners: team.students,
          target: target,
          created_at: 3.days.ago
        )
      end

      scenario "coach re-grades an old submission" do
        sign_in_user coach.user,
                     referrer:
                       review_timeline_event_path(submission_reviewed_old)
        click_button "Start Review"

        within(
          "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
        ) { find("button[title='Good']").click }

        within(
          "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
        ) { find("button[title='Okay']").click }

        click_button "Save grades"

        within("div[aria-label='submission-status']") do
          expect(page).to have_text("Completed")
        end

        expect(page).to have_text("Submission #1")
        expect(page).to have_text("2/4")
        expect(page).to have_text("1/3")

        click_link "Submission #2"

        expect(page).to have_text("Submission #2")
        expect(page).to have_text("4/4")
      end
    end
  end

  context "when evaluation criteria changed for a target with graded submissions" do
    let(:target_1) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group
    end
    let!(:submission_reviewed) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student],
        target: target_1,
        evaluator_id: coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:timeline_event_grade_1) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed,
        evaluation_criterion: evaluation_criterion_1
      )
    end
    let!(:timeline_event_grade_2) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed,
        evaluation_criterion: evaluation_criterion_2
      )
    end
    let!(:submission_pending) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student],
        target: target_1
      )
    end

    before do
      target_1.assignments.first.evaluation_criteria << [evaluation_criterion_1]
    end

    scenario "coach visits a submission and grades pending submission" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_reviewed)

      # Evaluation criteria at the point of grading are shown for reviewed submissions
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) do
        expect(page).to have_text(evaluation_criterion_1.name)
        expect(page).to have_text(
          "#{timeline_event_grade_1.grade}/#{evaluation_criterion_1.max_grade}"
        )
      end

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_2.id}']"
      ) do
        expect(page).to have_text(evaluation_criterion_2.name)
        expect(page).to have_text(
          "#{timeline_event_grade_2.grade}/#{evaluation_criterion_2.max_grade}"
        )
      end

      click_link "Submission #2"

      click_button "Start Review"

      # New list of evaluation criteria are shown for pending submissions
      expect(page).to have_text(evaluation_criterion_1.name)
      expect(page).not_to have_text(evaluation_criterion_2.name)

      # grades the pending submission
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) { find("button[title='Good']").click }

      click_button "Save grades"

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
      end
    end
  end

  context "with a reviewed submission that has feedback" do
    let!(:submission_reviewed) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student],
        target: target,
        evaluator_id: coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:feedback) do
      create(
        :startup_feedback,
        faculty_id: coach.id,
        timeline_event: submission_reviewed
      )
    end
    let!(:timeline_event_grade) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed,
        evaluation_criterion: evaluation_criterion_1
      )
    end

    scenario "team coach add his feedback" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_reviewed)
      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
        expect(page).to have_text("Evaluated By")
        expect(page).to have_text(coach.name)
      end

      expect(page).to have_button("Undo Grading")

      within("div[data-title='feedback-section']") do
        expect(page).to have_text(coach.name)
      end

      expect(page).to have_button("Add another feedback")
      click_button "Add another feedback"
      expect(page).not_to have_button("Add feedback")
      expect(page).to have_button("Share Feedback", disabled: true)

      feedback = Faker::Markdown.sandwich(sentences: 6)
      add_markdown(feedback)
      click_button "Share Feedback"

      expect(page).to have_text("Your feedback will be e-mailed to the student")

      dismiss_notification

      expect(page).to have_button("Add another feedback")

      open_email(student.email)
      expect(current_email.body).to include("Here is some additional feedback")

      submission = submission_reviewed.reload
      expect(submission.startup_feedback.count).to eq(2)
      expect(submission.startup_feedback.last.feedback).to eq(feedback)
    end

    scenario "team coach undo grading" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_reviewed)

      within("div[aria-label='submission-status']") do
        expect(page).to have_text("Completed")
        expect(page).to have_text("Evaluated By")
        expect(page).to have_text(coach.name)
      end

      accept_confirm { click_button "Undo Grading" }

      expect(page).to have_text("Start Review")

      submission = submission_reviewed.reload
      expect(submission.evaluator_id).to eq(nil)
      expect(submission.passed_at).to eq(nil)
      expect(submission.evaluated_at).to eq(nil)
      expect(submission.timeline_event_grades).to eq([])
    end

    scenario "coach clears grading for a submission with feedback" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_reviewed)

      accept_confirm { click_button "Undo Grading" }

      expect(submission_reviewed.startup_feedback.count).to eq(1)

      click_button "Start Review"

      within("div[data-title='feedback-section']") do
        expect(page).to have_text(coach.name)
        expect(page).to have_content(
          submission_reviewed.startup_feedback.first.feedback
        )
      end
    end
  end

  context "with an auto verified submission" do
    let(:auto_verified_submission) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student],
        target: auto_verify_target,
        passed_at: 1.day.ago
      )
    end

    scenario "coach visits submission review page" do
      sign_in_user team_coach.user,
                   referrer:
                     review_timeline_event_path(auto_verified_submission)

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end
  end

  context "when there are some submissions that have a mixed list of owners" do
    let(:target) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_TEAM,
             target_group: target_group
    end

    let(:team_1) { create :team_with_students, cohort: cohort }
    let(:team_2) { create :team_with_students, cohort: cohort }
    let(:team_2_student) { team_2.students.first }

    let!(:submission_reviewed_1) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [team_2_student] + team_1.students,
        target: target,
        evaluator_id: coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:submission_reviewed_2) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team_1.students + team_2.students,
        target: target,
        evaluator_id: coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:submission_reviewed_3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team_1.students + team_2.students,
        target: target,
        evaluator_id: coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:submission_reviewed_4) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team_1.students,
        target: target,
        evaluator_id: coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )
    end

    let!(:timeline_event_grade_1) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed_1,
        evaluation_criterion: evaluation_criterion_1
      )
    end
    let!(:timeline_event_grade_2) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed_2,
        evaluation_criterion: evaluation_criterion_1
      )
    end
    let!(:timeline_event_grade_3) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed_3,
        evaluation_criterion: evaluation_criterion_1
      )
    end
    let!(:timeline_event_grade_4) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed_4,
        evaluation_criterion: evaluation_criterion_1
      )
    end

    scenario "coach viewing a submission's review page is only shown other submissions with identical owners" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_reviewed_1)

      # submission 1
      expect(page).to have_text(submission_reviewed_1.checklist.first["title"])
      expect(page).to have_text(team_1.students.last.name)
      expect(page).to have_text(team_2_student.name)
      expect(page).to_not have_text(team_1.name)
      expect(page).to_not have_text(team_2.name)
      expect(page).not_to have_text(
        submission_reviewed_2.checklist.first["title"]
      )
      expect(page).not_to have_text(
        submission_reviewed_3.checklist.first["title"]
      )

      # submission 2 and 3
      visit review_timeline_event_path(submission_reviewed_3)

      expect(page).to have_text(team_1.students.last.name)
      expect(page).to have_text(team_2_student.name)
      expect(page).to have_link(
        href: "/submissions/#{submission_reviewed_3.id}/review"
      )
      expect(page).to have_link(
        href: "/submissions/#{submission_reviewed_2.id}/review"
      )
      expect(page).not_to have_link(
        href: "/submissions/#{submission_reviewed_1.id}/review"
      )
    end
  end

  context "when there are team targets and individual target submissions to review" do
    let(:individual_target) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group
    end
    let(:team_target) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_TEAM,
             target_group: target_group
    end
    let(:team_1) { create :team_with_students, cohort: cohort }
    let(:team_2) { create :team_with_students, cohort: cohort }
    let(:student) { team_1.students.first }
    let(:team_2_student) { team_2.students.first }

    let!(:submission_individual_target) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student],
        target: individual_target
      )
    end

    let!(:submission_team_target) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team_2.students,
        target: team_target
      )
    end

    let!(:submission_team_target_2) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student, team_2_student],
        target: team_target
      )
    end

    before do
      # Set evaluation criteria on the target so that its submissions can be reviewed.
      individual_target.assignments.first.evaluation_criteria << [
        evaluation_criterion_1
      ]
      team_target.assignments.first.evaluation_criteria << [
        evaluation_criterion_1
      ]
    end

    scenario "coaches are shown team name along with list of students if target is submitted by a team" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_team_target)

      expect(page).to have_title(
        "Submission #1 | #{team_target.title} | #{team_2.name}"
      )

      team_2.students.each { |student| expect(page).to have_text(student.name) }

      expect(page).to have_text(team_2.name)
    end

    scenario "coaches are shown just the name of the student if target is not a team target" do
      sign_in_user team_coach.user,
                   referrer:
                     review_timeline_event_path(submission_individual_target)

      expect(page).to have_title(
        "Submission #1 | #{individual_target.title} | #{student.name}"
      )

      expect(page).to have_text(student.name)
      expect(page).to_not have_text(team_1.name)
    end

    scenario "coaches are shown just the name of the students if current teams of students associated with submission are different" do
      sign_in_user team_coach.user,
                   referrer:
                     review_timeline_event_path(submission_team_target_2)
      expect(page).to have_title(
        "Submission #1 | #{team_target.title} | #{student.name}, #{team_2_student.name}"
      )
      expect(page).to have_text(student.name)
      expect(page).to have_text(team_2_student.name)
      expect(page).to_not have_text(team_1.name)
      expect(page).to_not have_text(team_2.name)
    end

    scenario "coaches are not shown report on automation tests in the absence of a submission report" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_team_target)

      expect(page).to have_title(
        "Submission #1 | #{team_target.title} | #{team_2.name}"
      )

      expect(page).to_not have_text("Automated tests are queued")
    end
  end

  context "student has undone submissions for a target" do
    let!(:submission_reviewed) do
      create(
        :timeline_event,
        :with_owners,
        latest: false,
        owners: [student],
        target: target,
        evaluator_id: coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 2.days.ago
      )
    end
    let!(:timeline_event_grade_1) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed,
        evaluation_criterion: evaluation_criterion_1
      )
    end
    let!(:timeline_event_grade_2) do
      create(
        :timeline_event_grade,
        timeline_event: submission_reviewed,
        evaluation_criterion: evaluation_criterion_2
      )
    end
    let!(:submission_archived) do
      create(
        :timeline_event,
        :with_owners,
        latest: false,
        owners: [student],
        target: target,
        archived_at: 1.day.ago
      )
    end
    let!(:submission_pending) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student],
        target: target
      )
    end

    scenario "coach attempts to access the review page for an archived submission" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_archived)

      expect(page).to have_text("The page you were looking for doesn't exist")
    end

    scenario "coach visits pending submission and finds archived submission in history" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      expect(page).to have_selector(".submission-info__tab", count: 3)

      expect(page).not_to have_link(
        href: "/submissions/#{submission_archived.id}/review"
      )

      within("a[title='Submission #1']") do
        expect(page).to have_text("Submission #1")
        expect(page).to have_text("Completed")
      end

      within("div[title='Submission #2']") do
        expect(page).to have_text("Submission #2")
        expect(page).to have_text("Deleted")
      end

      within("a[title='Submission #3']") do
        expect(page).to have_text("Submission #3")
        expect(page).to have_text("Pending Review")
      end
    end
  end

  context "when a submission report exists for a submission" do
    let!(:submission_with_report) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target
      )
    end
    let!(:submission_report_1) do
      create :submission_report, :queued, submission: submission_with_report
    end

    let!(:submission_report_2) do
      create :submission_report, :queued, submission: submission_with_report
    end

    around do |example|
      with_secret(submission_report_poll_time: 2) { example.run }
    end

    scenario "indicates the status of the automated test in submission review page" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_with_report)
      expect(page).to have_text("Actions are queued")
      expect(page).to have_text(submission_report_1.reporter)
      expect(page).to have_text(submission_report_2.reporter)
      expect(page).to_not have_button("Show Report")

      submission_report_1.update!(
        status: "in_progress",
        started_at: 2.minutes.ago
      )
      refresh
      expect(page).to have_text("Actions are in progress")
      expect(page).to have_text("Started 2 minutes ago")

      submission_report_1.update!(
        status: "success",
        started_at: 2.minutes.ago,
        completed_at: Time.zone.now,
        report: "Foo"
      )
      refresh
      expect(page).to have_text("All actions succeeded")
      expect(page).to_not have_text("Foo")
      click_button "Show Report"
      expect(page).to have_text("Foo")

      submission_report_1.update!(
        status: "failure",
        started_at: 2.minutes.ago,
        completed_at: Time.zone.now,
        report: "Bar"
      )
      refresh
      expect(page).to have_text("Some actions failed")
      click_button "Show Report"
      expect(page).to have_text("Bar")
    end

    scenario "status of the report is checked every 30 seconds without page reload if current status is not completed" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_with_report)
      expect(page).to have_text("Actions are queued")
      submission_report_2.update!(
        status: "success",
        report: "A new report description",
        heading: "All automated tests succeeded",
        started_at: 2.minutes.ago,
        completed_at: Time.zone.now
      )
      sleep 2
      expect(page).to have_text("All automated tests succeeded")
      click_button "Show Report"
      expect(page).to have_text("A new report description")
    end
  end

  context "When a milestone submission is ungraded after the course is marked complete for a student" do
    let(:target_3) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group,
             given_milestone_number: 1,
             given_evaluation_criteria: [evaluation_criterion_1]
    end

    let!(:submission_3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team.students,
        target: target_3,
        evaluator_id: team_coach.id,
        evaluated_at: nil,
        passed_at: nil
      )
    end

    scenario "coach grades and than ungrades milestone submission" do
      sign_in_user team_coach.user,
                   referrer: review_timeline_event_path(submission_3)

      click_button "Start Review"
      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion_1.id}']"
      ) do
        expect(page).to have_selector(
          ".course-review-editor__grade-pill",
          count: 4
        )
        find("button[title='Great']").click
      end

      click_button "Save grades"

      expect(page).to have_button("Undo Grading")
      expect(team.students.reload.pluck(:completed_at)).not_to eq([nil, nil])

      accept_confirm { click_button("Undo Grading") }

      expect(page).to have_button("Start Review")
      expect(team.students.reload.pluck(:completed_at)).to eq([nil, nil])
    end
  end
end
