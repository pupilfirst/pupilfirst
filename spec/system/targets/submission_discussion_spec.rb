require "rails_helper"

feature "Assignment Discussion", js: true do
  include UserSpecHelper
  include NotificationHelper
  include HtmlSanitizerSpecHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, school: school, public_preview: true }
  let!(:cohort) { create :cohort, course: course }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let!(:team) { create :team_with_students, cohort: cohort }
  let!(:student) { team.students.first }
  let!(:student_same_team) { create :student, cohort: cohort, team: team }
  let!(:another_student) { create :student, cohort: cohort }
  let(:coach) { create :faculty, school: school }
  let(:school_admin) { create :school_admin }

  let!(:target) do
    create :target, :with_content, target_group: target_group, sort_index: 0
  end

  let!(:assignment_target) do
    create :assignment,
           :with_completion_instructions,
           :with_default_checklist,
           target: target,
           role: Assignment::ROLE_STUDENT,
           discussion: true,
           allow_anonymous: true
  end

  before do
    create :faculty_cohort_enrollment, faculty: coach, cohort: cohort

    school.school_strings.create!(
      key: SchoolString::EmailAddress.key,
      value: "test@school.com"
    )
  end

  scenario "a member of public views a preview of the discussion assignment" do
    visit target_path(target)

    find(".course-overlay__body-tab-item", text: "Submit Form").click

    expect(page).to have_text("Discussion enabled assignment")
    expect(page).to_not have_text("Submissions by peers")
  end

  scenario "the first student visits a new assignment's page" do
    sign_in_user student.user, referrer: target_path(target)
    find(".course-overlay__body-tab-item", text: "Submit Form").click

    expect(page).to have_text("Submissions by peers")
    expect(page).to have_text("There are no submissions yet")
  end

  context "when a student has a submission" do
    let!(:student_submission) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target
      )
    end

    scenario "student can react to and comment on, but not report their own submission" do
      sign_in_user student.user, referrer: target_path(target)

      find(".course-overlay__body-tab-item", text: "Form Responses").click

      expect(page).to have_text("Your Responses")
      expect(page).to have_text("Submissions by peers")
      expect(page).to have_button("Comment", disabled: true)
      expect(page).to have_button("Add reaction")

      expect(page).to_not have_button("Report")
    end
  end

  context "with a submission from a different student" do
    let!(:another_student_submission) do
      create(
        :timeline_event,
        :with_owners,
        :has_checklist_with_image_file,
        file_user: another_student.user,
        owners: [another_student],
        latest: true,
        target: target
      )
    end

    scenario "student can view the files attached to the peer's submission" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")
      expect(page).to have_text(another_student.name)

      expect(page).to have_text("icon_pupilfirst.png")

      # click_link "icon_pupilfirst.png" is not working in this test
      path = find("a", text: "icon_pupilfirst.png")[:href]

      visit path

      expect(current_url).not_to include("download")
      expect(current_url).not_to include("targets")
      expect(current_url).to include("icon_pupilfirst.png")
    end

    scenario "student views assigment page with peer's submission, without the option to pin or hide it" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")
      expect(page).to_not have_text("There are no submissions yet")
      expect(page).to have_text(another_student.name)
      expect(page).to have_button("Comment", disabled: true)
      expect(page).to have_button("Add reaction")

      find(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ).hover

      expect(page).to have_button("Report")
      expect(page).to_not have_button("Pin")
      expect(page).to_not have_button("Hide submission")
    end

    context "when that submission is anonymous" do
      let!(:another_student_submission) do
        create(
          :timeline_event,
          :with_owners,
          owners: [another_student],
          latest: true,
          target: target,
          anonymous: true
        )
      end

      scenario "student views assigment page with the peer submission, minus the identity of the other student" do
        sign_in_user student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to have_text("Submissions by peers")
        expect(page).to_not have_text("There are no submissions yet")

        expect(page).to_not have_text(another_student.name)
        expect(page).to have_text("Anonymous")
      end
    end

    scenario "student reports their peer's submission" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")

      find(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ).hover
      expect(page).to have_button("Report")
      click_button "Report"

      within("dialog") do
        expect(page).to have_button("Report", disabled: true)
        fill_in "report_reason-#{another_student_submission.id}",
                with: "Offensive content"
        click_button "Report"
      end

      expect(page).to have_text("Reported")
      open_email(student.email)
      expect(current_email.body).to include(
        "Your report of the content on the discussions for target"
      )
      page.refresh
      find(".course-overlay__body-tab-item", text: "Submit Form").click
      expect(page).to have_text("Reported")
    end

    scenario "student adds reaction to peer's submission" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")

      within(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ) do
        expect(page).to have_text(another_student.name)
        click_button "Add reaction"
      end

      shadow_root = find("em-emoji-picker").shadow_root
      within(shadow_root) do
        expect(page).to have_text("Smileys & People")
        find("button", text: "😀", match: :first).click
      end

      within(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ) do
        expect(page).to have_text(another_student.name)
        expect(page).to have_button("😀")
      end

      # Check that the reaction is visible after a page refresh
      page.refresh
      find(".course-overlay__body-tab-item", text: "Submit Form").click
      within(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ) do
        expect(page).to have_text(another_student.name)
        expect(page).to have_button("😀")
      end

      within(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ) do
        expect(page).to have_text(another_student.name)
        click_button "Add reaction"
      end

      # Attempt to add the same reaction again via the emoji picker.
      within(find("em-emoji-picker").shadow_root) do
        find("button", text: "😀", match: :first).click
      end

      expect(page).not_to have_selector("em-emoji-picker")
      sleep 0.5 # Wait for the server to process the request

      reaction_count =
        student
          .user
          .reactions
          .where(reactionable: another_student_submission)
          .count

      expect(reaction_count).to eq(1)
    end

    context "when that submission has an existing reaction" do
      let!(:existing_reaction) do
        create(
          :reaction,
          reactionable: another_student_submission,
          user: another_student.user,
          reaction_value: "😀"
        )
      end

      scenario "student adds to the existing reaction, and then removes it" do
        sign_in_user student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click
        expect(page).to have_text("Submissions by peers")

        expect(page).to have_button("😀")
        click_button "😀"

        find("button > span", text: "😀").hover
        within(".modal") do
          expect(page).to have_text(another_student.name)
          expect(page).to have_text(student.name)
        end

        click_button "😀"
        find("button > span", text: "😀").hover
        within(".modal") do
          expect(page).to have_text(another_student.name)
          expect(page).to_not have_text(student.name)
        end
      end
    end

    scenario "student adds and deletes a comment on peer's submission" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")

      within("div[data-submission-id='#{another_student_submission.id}']") do
        expect(page).to have_button("Comment", disabled: true)

        fill_in "add_comment-#{another_student_submission.id}",
                with: "Great work!"
        click_button "Comment"

        expect(page).to have_text(student.name)
        expect(page).to have_text("Great work!")
      end

      open_email(another_student.email)
      expect(current_email.subject).to include("New comment on your submission")
      body = sanitize_html(current_email.body)
      expect(body).to include(
        "#{student.name} has left a comment on your discussion assignment submission. Here is the comment:"
      )
      expect(body).to include("Great work!")
      expect(body).to include(
        "http://test.host/targets/#{target.id}?comment_id=#{SubmissionComment.last.id}&submission_id=#{another_student_submission.id}"
      )

      page.refresh

      find(".course-overlay__body-tab-item", text: "Submit Form").click

      comment = student.user.submission_comments.first
      comment_id = comment.id

      find("div#show_comments-#{another_student_submission.id} button").click

      within("div[data-submission-id='#{another_student_submission.id}']") do
        expect(page).to have_text(student.name)
        expect(page).to have_text("Great work!")

        find("div[aria-label='comment-#{comment_id}']").hover

        expect(page).to have_button("Delete")
        expect(page).to_not have_button("Report")
        expect(page).to_not have_button("Hide")
      end

      within("div#comment-#{comment_id}") do
        find("div[aria-label='comment-#{comment_id}']").hover
        expect(page).to have_button("Delete")
        click_button "Delete"

        within("dialog") do
          expect(page).to have_button("Delete")
          click_button "Delete"
        end
      end

      within("div[data-submission-id='#{another_student_submission.id}']") do
        expect(page).to_not have_text(student.name)
        expect(page).to_not have_text("Great work!")
      end

      page.refresh

      find(".course-overlay__body-tab-item", text: "Submit Form").click

      within("div[data-submission-id='#{another_student_submission.id}']") do
        expect(page).to_not have_text(student.name)
        expect(page).to_not have_text("Great work!")
        expect(page).to have_button("Comment", disabled: true)
      end

      expect(student.user.submission_comments.first.archived_at).not_to eq(nil)
    end

    scenario "student adds a reaction to their own comment" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")

      within("div[data-submission-id='#{another_student_submission.id}']") do
        expect(page).to have_button("Comment", disabled: true)
        fill_in "add_comment-#{another_student_submission.id}",
                with: "Great work!"
        click_button "Comment"

        expect(page).to have_text(student.name)
        expect(page).to have_text("Great work!")

        click_button "Add reaction"
      end

      shadow_root = find("em-emoji-picker").shadow_root
      within(shadow_root) do
        expect(page).to have_text("Smileys & People")
        find("button", text: "😀", match: :first).click
      end

      expect(page).not_to have_selector("em-emoji-picker")
      expect(page).to have_button("😀")
    end

    context "when that submission already has a comment" do
      let!(:another_student_comment) do
        create(
          :submission_comment,
          submission: another_student_submission,
          user: another_student.user
        )
      end

      scenario "student reports the comment" do
        sign_in_user student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to have_text("Submissions by peers")
        find("div#show_comments-#{another_student_submission.id} button").click

        expect(page).to have_text(another_student.name)
        expect(page).to have_text(another_student_comment.comment)

        find("div[aria-label='comment-#{another_student_comment.id}']").hover
        within("div[aria-label='comment-#{another_student_comment.id}']") do
          expect(page).to_not have_button("Delete")
          expect(page).to have_button("Report")
          click_button "Report"
        end

        within("dialog") do
          expect(page).to have_button("Report", disabled: true)
          fill_in "report_reason-#{another_student_comment.id}",
                  with: "Offensive content"
          click_button "Report"
        end

        within("div[aria-label='comment-#{another_student_comment.id}']") do
          expect(page).to have_text("Reported")
        end
      end
    end
  end

  context "with submissions from two students" do
    let!(:student_submission) do
      create(
        :timeline_event,
        :with_owners,
        owners: [student],
        latest: true,
        target: target
      )
    end

    let!(:another_student_submission) do
      create(
        :timeline_event,
        :with_owners,
        owners: [another_student],
        latest: true,
        target: target
      )
    end

    scenario "school admin views submissions on the Submit Form tab with all moderation options" do
      sign_in_user school_admin.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")
      expect(page).to_not have_text("There are no submissions yet")

      within("div#discuss_submission-#{student_submission.id}") do
        expect(page).to have_text(student.name)
        expect(page).to have_button("Comment", disabled: true)
        expect(page).to have_button("Add reaction")
      end

      find(
        "div[aria-label='discuss_submission-#{student_submission.id}']"
      ).hover

      within("div#discuss_submission-#{student_submission.id}") do
        expect(page).to have_button("Pin")
        expect(page).to have_button("Hide submission")
        expect(page).to have_button("Report")
      end

      within("div#discuss_submission-#{another_student_submission.id}") do
        expect(page).to have_text(another_student.name)
        expect(page).to have_button("Comment", disabled: true)
        expect(page).to have_button("Add reaction")
      end
    end

    scenario "course coach views submissions on the Submit Form tab with all moderation options" do
      sign_in_user coach.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")
      expect(page).to_not have_text("There are no submissions yet")

      within("div#discuss_submission-#{student_submission.id}") do
        expect(page).to have_text(student.name)
        expect(page).to have_button("Comment", disabled: true)
        expect(page).to have_button("Add reaction")
      end

      find(
        "div[aria-label='discuss_submission-#{student_submission.id}']"
      ).hover

      within("div#discuss_submission-#{student_submission.id}") do
        expect(page).to have_button("Pin")
        expect(page).to have_button("Hide submission")
        expect(page).to have_button("Report")
      end

      within("div#discuss_submission-#{another_student_submission.id}") do
        expect(page).to have_text(another_student.name)
        expect(page).to have_button("Comment", disabled: true)
        expect(page).to have_button("Add reaction")
      end
    end

    scenario "school admin hides a submission" do
      sign_in_user school_admin.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click
      expect(page).to have_text("Submissions by peers")

      find(
        "div[aria-label='discuss_submission-#{student_submission.id}']"
      ).hover

      within("div#discuss_submission-#{student_submission.id}") do
        click_button "Hide submission"
        expect(page).to_not have_button("Hide submission")
        expect(page).to have_button("Un-hide submission")
        expect(page).to have_text("This submission is hidden from discussions")
      end

      expect(student_submission.reload.hidden_at).to_not eq(nil)
      expect(student_submission.reload.hidden_by_id).to eq(school_admin.user.id)

      sign_in_user another_student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Form Responses").click
      expect(page).to have_text("Submissions by peers")

      expect(page).to_not have_text(student.name)
      expect(page).to have_text("There are no submissions yet")
    end

    scenario "school admin pins and unpins a submission" do
      sign_in_user school_admin.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click
      expect(page).to have_text("Submissions by peers")

      find(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ).hover

      within("div#discuss_submission-#{another_student_submission.id}") do
        click_button "Pin"
        expect(page).to have_text("Pinned Submission")
      end

      expect(another_student_submission.reload.pinned).to eq(true)

      find(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ).hover

      within("div#discuss_submission-#{another_student_submission.id}") do
        expect(page).to_not have_button("Pin")
        click_button "Unpin"
        expect(page).to_not have_text("Pinned Submission")
      end

      expect(another_student_submission.reload.pinned).to eq(false)

      find(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ).hover
      within("div#discuss_submission-#{another_student_submission.id}") do
        click_button "Pin"
        expect(page).to have_text("Pinned Submission")
      end

      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Form Responses").click
      expect(page).to have_text("Submissions by peers")

      within("div#discuss_submission-#{another_student_submission.id}") do
        expect(page).to have_text("Pinned Submission")
      end
    end

    context "with comments on a submission" do
      let!(:student_comment) do
        create(
          :submission_comment,
          submission: another_student_submission,
          user: student.user
        )
      end

      let!(:another_student_comment) do
        create(
          :submission_comment,
          submission: another_student_submission,
          user: another_student.user
        )
      end

      scenario "school admin hides and unhides comments" do
        sign_in_user school_admin.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to have_text("Submissions by peers")
        find("div#show_comments-#{another_student_submission.id} button").click

        find("div[aria-label='comment-#{student_comment.id}']").hover
        within("div#comment-#{student_comment.id}") do
          expect(page).to have_text(student.name)
          expect(page).to have_text(student_comment.comment)
          expect(page).to_not have_button("Delete")
          expect(page).to have_button("Report")
          expect(page).to have_button("Hide")
        end

        find("div[aria-label='comment-#{another_student_comment.id}']").hover

        within("div#comment-#{another_student_comment.id}") do
          expect(page).to have_text(another_student.name)
          expect(page).to have_text(another_student_comment.comment)
          expect(page).to_not have_button("Delete")

          click_button "Hide"

          expect(page).to have_text("This comment is hidden from discussions")
          expect(page).to_not have_button("Hide")
          expect(page).to have_button("Un-hide")
        end

        expect(another_student_comment.reload.hidden_at).to_not eq(nil)

        expect(another_student_comment.reload.hidden_by_id).to eq(
          school_admin.user.id
        )

        within("div#comment-#{another_student_comment.id}") do
          click_button "Un-hide"

          expect(page).to_not have_text(
            "This comment is hidden from discussions"
          )
          expect(page).to_not have_button("Un-hide")
          expect(page).to have_button("Hide")
        end

        expect(another_student_comment.reload.hidden_at).to eq(nil)
        expect(another_student_comment.reload.hidden_by_id).to eq(nil)

        within("div#comment-#{another_student_comment.id}") do
          click_button "Hide"
          expect(page).to have_text("This comment is hidden from discussions")
        end
      end

      context "when a student's comment has been hidden" do
        before do
          another_student_comment.update!(
            hidden_at: 1.minute.ago,
            hidden_by: school_admin.user
          )
        end
        scenario "a different student is not able to see the hidden comment" do
          sign_in_user student.user, referrer: target_path(target)
          find(".course-overlay__body-tab-item", text: "Form Responses").click

          expect(page).to have_text("Submissions by peers")

          find(
            "div#show_comments-#{another_student_submission.id} button"
          ).click

          within(
            "div[data-submission-id='#{another_student_submission.id}']"
          ) do
            expect(page).to have_text(student.name)
            expect(page).to have_text(student_comment.comment)

            expect(page).to_not have_text(another_student.name)
            expect(page).to_not have_text(another_student_comment.comment)
          end
        end

        scenario "student whose comment is hidden can see that it is hidden, but can't un-hide it" do
          sign_in_user another_student.user, referrer: target_path(target)
          find(".course-overlay__body-tab-item", text: "Form Responses").click
          expect(page).to have_text("Submissions by peers")

          find(
            "div#show_comments-#{another_student_submission.id} button"
          ).click

          within(
            "div[data-submission-id='#{another_student_submission.id}']"
          ) do
            expect(page).to have_text(student.name)
            expect(page).to have_text(student_comment.comment)

            expect(page).to have_text(another_student.name)
            expect(page).to have_text(another_student_comment.comment)
          end

          find("div[aria-label='comment-#{another_student_comment.id}']").hover

          within("div#comment-#{another_student_comment.id}") do
            expect(page).to have_text("This comment is hidden from discussions")
            expect(page).to_not have_button("Un-hide")
          end
        end
      end
    end
  end

  context "with more than 10 peer submissions" do
    let!(:another_student_submissions) do
      create_list(
        :timeline_event,
        14,
        :with_owners,
        owners: [another_student],
        target: target
      )
    end
    let!(:another_student_submission) do
      create(
        :timeline_event,
        :with_owners,
        owners: [another_student],
        latest: true,
        target: target
      )
    end

    scenario "student views the first 10 submissions, and then loads more" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")
      expect(page).to have_content("Showing 10 of 15 submissions")

      within(
        "div[aria-label='discuss_submission-#{another_student_submission.id}']"
      ) { expect(page).to have_text(another_student.name) }

      click_button "Load More"

      expect(page).to have_text("Showing all 15 submissions")
    end
  end

  context "when the discussion feature is disabled" do
    let!(:assignment_target) do
      create :assignment,
             :with_completion_instructions,
             :with_default_checklist,
             target: target,
             role: Assignment::ROLE_STUDENT,
             discussion: false,
             allow_anonymous: false
    end

    scenario "student is not shown the option to view submissions from peers" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to_not have_text("Submissions by peers")
    end
  end
end
