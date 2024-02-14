require "rails_helper"

feature "Assignment Discussion", js: true do
  include UserSpecHelper
  include NotificationHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
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

  context "when the user is a student" do
    context "when discussion is disabled" do
      let!(:assignment_target) do
        create :assignment,
               :with_completion_instructions,
               :with_default_checklist,
               target: target,
               role: Assignment::ROLE_STUDENT,
               discussion: false,
               allow_anonymous: false
      end

      scenario "views the target complete section" do
        sign_in_user student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to_not have_text("Submissions by peers")
      end

      context "with own submission" do
        let!(:submission_student) do
          create(
            :timeline_event,
            :with_owners,
            owners: [student],
            latest: true,
            target: target
          )
        end

        scenario "views target complete section" do
          sign_in_user student.user, referrer: target_path(target)

          find(".course-overlay__body-tab-item", text: "Form Responses").click

          expect(page).to have_text("Your Responses")
          expect(page).to_not have_text("Submissions by peers")
          expect(page).to_not have_button("Comment")
          expect(page).to_not have_button("Add reaction")
        end
      end
    end

    context "with own submission" do
      let!(:student_submission) do
        create(
          :timeline_event,
          :with_owners,
          owners: [student],
          latest: true,
          target: target
        )
      end

      scenario "views target complete section" do
        sign_in_user student.user, referrer: target_path(target)

        find(".course-overlay__body-tab-item", text: "Form Responses").click

        expect(page).to have_text("Your Responses")
        expect(page).to have_text("Submissions by peers")
        expect(page).to have_button("Comment")
        expect(page).to have_button("Add reaction")

        expect(page).to_not have_button("Report")
      end
    end

    scenario "views target complete with no peer submissions" do
      sign_in_user student.user, referrer: target_path(target)
      find(".course-overlay__body-tab-item", text: "Submit Form").click

      expect(page).to have_text("Submissions by peers")
      expect(page).to have_text("There are no submissions yet")
    end

    context "with peer submissions" do
      let!(:another_student_submission) do
        create(
          :timeline_event,
          :with_owners,
          owners: [another_student],
          latest: true,
          target: target
        )
      end

      scenario "views target complete section" do
        sign_in_user student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to have_text("Submissions by peers")
        expect(page).to_not have_text("There are no submissions yet")

        expect(page).to have_text(another_student.name)
        expect(page).to have_button("Comment")
        expect(page).to have_button("Add reaction")

        find(
          "div[aria-label='discuss_submission-#{another_student_submission.id}']"
        ).hover
        expect(page).to have_button("Report")
        expect(page).to_not have_button("Pin")
        expect(page).to_not have_button("Hide submission")
      end

      context "submission is anonymous" do
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
        scenario "views target complete section" do
          sign_in_user student.user, referrer: target_path(target)
          find(".course-overlay__body-tab-item", text: "Submit Form").click

          expect(page).to have_text("Submissions by peers")
          expect(page).to_not have_text("There are no submissions yet")

          expect(page).to_not have_text(another_student.name)
          expect(page).to have_text("Anonymous")
          expect(page).to have_button("Comment")
          expect(page).to have_button("Add reaction")

          find(
            "div[aria-label='discuss_submission-#{another_student_submission.id}']"
          ).hover
          expect(page).to have_button("Report")
          expect(page).to_not have_button("Pin")
          expect(page).to_not have_button("Hide submission")
        end
      end

      scenario "reports a peer submission" do
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

      scenario "adds and removes a new reaction" do
        #TODO - figure out how to click on emoji picker
      end

      context "with an existing reaction" do
        let!(:existing_reaction) do
          create(
            :reaction,
            reactionable: another_student_submission,
            user: another_student.user,
            reaction_value: "😀"
          )
        end

        scenario "adds and removes the existing reaction" do
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

      scenario "adds and deletes a comment on a peer submission" do
        sign_in_user student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to have_text("Submissions by peers")

        find("div#show_comments-#{another_student_submission.id} button").click

        within(".submissionComments") do
          expect(page).to have_button("Comment", disabled: true)
          fill_in "add_comment-#{another_student_submission.id}",
                  with: "Great work"
          click_button "Comment"

          expect(page).to have_text(student.name)
          expect(page).to have_text("Great work")
        end

        page.refresh
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        comment = student.user.submission_comments.first
        comment_id = comment.id

        find("div#show_comments-#{another_student_submission.id} button").click
        within(".submissionComments") do
          expect(page).to have_text(student.name)
          expect(page).to have_text("Great work")
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

        within(".submissionComments") do
          expect(page).to_not have_text(student.name)
          expect(page).to_not have_text("Great work")
        end

        page.refresh
        find(".course-overlay__body-tab-item", text: "Submit Form").click
        find("div#show_comments-#{another_student_submission.id} button").click

        within(".submissionComments") do
          expect(page).to_not have_text(student.name)
          expect(page).to_not have_text("Great work")
        end

        expect(student.user.submission_comments.first.archived_at).not_to eq(
          nil
        )
      end

      scenario "adds new reaction to own comment" do
        sign_in_user student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to have_text("Submissions by peers")

        find("div#show_comments-#{another_student_submission.id} button").click

        within(".submissionComments") do
          expect(page).to have_button("Comment", disabled: true)
          fill_in "add_comment-#{another_student_submission.id}",
                  with: "Great work"
          click_button "Comment"

          expect(page).to have_text(student.name)
          expect(page).to have_text("Great work")

          click_button "Add reaction"
          expect(page).to have_text("Smileys & People")
          #TODO - figure out how to click on emoji picker
        end
      end

      context "with another student comment" do
        let!(:another_student_comment) do
          create(
            :submission_comment,
            timeline_event: another_student_submission,
            user: another_student.user
          )
        end
        scenario "reports the comment" do
          sign_in_user student.user, referrer: target_path(target)
          find(".course-overlay__body-tab-item", text: "Submit Form").click

          expect(page).to have_text("Submissions by peers")
          find(
            "div#show_comments-#{another_student_submission.id} button"
          ).click

          within(".submissionComments") do
            expect(page).to have_text(another_student.name)
            expect(page).to have_text(another_student_comment.comment)
          end

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
  end

  context "when the user is a school admin" do
    context "with peer submissions" do
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

      scenario "views target complete section" do
        sign_in_user school_admin.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Submit Form").click

        expect(page).to have_text("Submissions by peers")
        expect(page).to_not have_text("There are no submissions yet")

        within("div#discuss_submission-#{student_submission.id}") do
          expect(page).to have_text(student.name)
          expect(page).to have_button("Comment")
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
          expect(page).to have_button("Comment")
          expect(page).to have_button("Add reaction")
        end
      end

      scenario "hides a submission" do
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
          expect(page).to have_button("Pin", disabled: true)
          expect(page).to have_text(
            "This submission is hidden from discussions"
          )
        end

        expect(student_submission.reload.hidden_at).to_not eq(nil)
        expect(student_submission.reload.hidden_by_id).to eq(
          school_admin.user.id
        )

        sign_in_user another_student.user, referrer: target_path(target)
        find(".course-overlay__body-tab-item", text: "Form Responses").click
        expect(page).to have_text("Submissions by peers")

        expect(page).to_not have_text(student.name)
        expect(page).to have_text("There are no submissions yet")
      end

      scenario "pins and unpins a submission" do
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

      context "with other student comments" do
        let!(:student_comment) do
          create(
            :submission_comment,
            timeline_event: another_student_submission,
            user: student.user
          )
        end
        let!(:another_student_comment) do
          create(
            :submission_comment,
            timeline_event: another_student_submission,
            user: another_student.user
          )
        end

        scenario "hides one of the comment" do
          sign_in_user school_admin.user, referrer: target_path(target)
          find(".course-overlay__body-tab-item", text: "Submit Form").click

          expect(page).to have_text("Submissions by peers")
          find(
            "div#show_comments-#{another_student_submission.id} button"
          ).click

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
            expect(page).to have_button("Report")
            expect(page).to have_button("Hide")
          end

          within("div#comment-#{another_student_comment.id}") do
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

          #Another user is not able to see the hidden comments
          sign_in_user student.user, referrer: target_path(target)
          find(".course-overlay__body-tab-item", text: "Form Responses").click
          expect(page).to have_text("Submissions by peers")

          find(
            "div#show_comments-#{another_student_submission.id} button"
          ).click

          within(".submissionComments") do
            expect(page).to have_text(student.name)
            expect(page).to have_text(student_comment.comment)

            expect(page).to_not have_text(another_student.name)
            expect(page).to_not have_text(another_student_comment.comment)
          end

          #User whose comment is hidden can see that it is hidden, but can't Un-hide
          sign_in_user another_student.user, referrer: target_path(target)
          find(".course-overlay__body-tab-item", text: "Form Responses").click
          expect(page).to have_text("Submissions by peers")

          find(
            "div#show_comments-#{another_student_submission.id} button"
          ).click

          within(".submissionComments") do
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
end
