require "rails_helper"

feature "Automatic issuance of certificates", js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper
  include SubmissionsHelper
  include HtmlSanitizerSpecHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let!(:certificate) { create :certificate, :active, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }

  # Create few teams
  let!(:team) { create :team, cohort: cohort }

  # Shortcut to a student we'll refer to frequently.
  let!(:student_1) { create :student, cohort: cohort, team: team }
  let!(:student_2) { create :student, cohort: cohort, team: team }

  let(:target_group_l1) { create :target_group, level: level_1 }
  let(:target_group_l2) { create :target_group, level: level_2 }

  let!(:target_l1) do
    create :target,
           :with_markdown,
           :with_shared_assignment,
           target_group: target_group_l1,
           given_role: Assignment::ROLE_TEAM,
           given_milestone_number: 1
  end

  let!(:target_l2) do
    create :target,
           :with_markdown,
           :with_shared_assignment,
           target_group: target_group_l2,
           given_role: Assignment::ROLE_TEAM,
           given_milestone_number: 2
  end

  before do
    # Add one archived target; it shouldn't interfere with issuance of certificates.
    create :target, :with_markdown, :archived, target_group: target_group_l2
  end

  def complete_milestone(target, visit: false)
    if visit
      visit target_path(target)
    else
      sign_in_user student_1.user, referrer: target_path(target)
    end

    find(".course-overlay__body-tab-item", text: "Submit Form").click
    replace_markdown Faker::Lorem.sentence
    click_button "Submit"

    # No certificate should be issued at this point.
    expect(student_1.user.issued_certificates.count).to eq(0)

    dismiss_notification
    click_button "Close"
  end

  scenario "student completes one milestone" do
    sign_in_user student_1.user, referrer: target_path(target_l1)

    find(".course-overlay__body-tab-item", text: "Submit Form").click
    replace_markdown Faker::Lorem.sentence
    click_button "Submit"

    # No certificate should be issued.
    expect(IssuedCertificate.count).to eq(0)
  end

  scenario "student completes both milestones" do
    complete_milestone(target_l1)

    visit target_path(target_l2)

    find(".course-overlay__body-tab-item", text: "Submit Form").click
    replace_markdown Faker::Lorem.sentence
    click_button "Submit"

    expect(page).to have_content("Your response has been saved.")

    expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(
      student_1.user.id,
      student_2.user.id
    )

    # Check the details of the first certificate.
    issued_certificate = student_1.user.issued_certificates.first

    expect(issued_certificate.certificate).to eq(certificate)
    expect(issued_certificate.name).to eq(student_1.name)
    expect(issued_certificate.serial_number).to match(/^\d{6}-[A-Z0-9]{6}$/)

    # Two emails should also have been sent out.
    open_email(student_1.email)

    expect(sanitize_html(current_email.body)).to include(
      "http://test.host/c/#{issued_certificate.serial_number}"
    )

    open_email(student_2.email)

    expect(sanitize_html(current_email.body)).to include(
      "http://test.host/c/#{student_2.user.issued_certificates.first.serial_number}"
    )
  end

  context "when there are multiple milestones" do
    let(:target_group_l2_2) { create :target_group, level: level_2 }

    context "when the second target is completed with a quiz" do
      let!(:quiz) { create :quiz, :with_question_and_answers }
      let!(:target_l2_2) do
        create :target,
               :with_markdown,
               target_group: target_group_l2,
               title: "foo"
      end
      let!(:assignment_target_l2_2) do
        create :assignment,
               role: Assignment::ROLE_TEAM,
               milestone: true,
               milestone_number: 3,
               quiz: quiz,
               checklist: [],
               target: target_l2_2
      end

      scenario "student completed second and final milestone" do
        complete_milestone(target_l1)
        complete_milestone(target_l2, visit: true)

        visit target_path(target_l2_2)

        find(".course-overlay__body-tab-item", text: "Take Quiz").click
        find(
          ".quiz-root__answer",
          text: quiz.quiz_questions.first.answer_options.first.value
        ).click
        click_button("Submit Quiz")

        expect(page).to have_content("Your responses have been saved")

        # Both students should have a certificate at this point.
        expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(
          student_1.user.id,
          student_2.user.id
        )
      end
    end

    context "when the second target is a form submission" do
      let!(:target_l2_2) do
        create :target,
               :with_markdown,
               :with_shared_assignment,
               given_role: Assignment::ROLE_TEAM,
               given_milestone_number: 3,
               target_group: target_group_l2,
               title: "foo"
      end

      scenario "student completed second and final milestone" do
        complete_milestone(target_l1)
        complete_milestone(target_l2, visit: true)

        visit target_path(target_l2_2)

        find(".course-overlay__body-tab-item", text: "Submit Form").click
        replace_markdown Faker::Lorem.sentence
        click_button "Submit"

        expect(page).to have_content("Your response has been saved.")

        # Both students should have a certificate at this point.
        expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(
          student_1.user.id,
          student_2.user.id
        )
      end
    end

    context "when the second target also requires submission and review" do
      let(:evaluation_criterion) do
        create :evaluation_criterion, course: course
      end
      let!(:target_l2_2) do
        create :target,
               :with_markdown,
               :with_shared_assignment,
               given_role: Assignment::ROLE_TEAM,
               given_milestone_number: 3,
               given_evaluation_criteria: [evaluation_criterion],
               target_group: target_group_l2,
               title: "foo"
      end

      let(:coach) { create :faculty, user: student_1.user }

      before do
        create :faculty_cohort_enrollment, faculty: coach, cohort: cohort
      end

      scenario "student completed second and final milestone" do
        complete_milestone(target_l1)
        complete_milestone(target_l2, visit: true)

        visit target_path(target_l2_2)

        find(".course-overlay__body-tab-item", text: "Complete").click
        replace_markdown Faker::Lorem.sentence
        click_button "Submit"

        expect(page).to have_content(
          "Your submission has been queued for review"
        )

        # No issued certificates, yet.
        expect(IssuedCertificate.count).to eq(0)

        # Switch to the review interface and reject the submission
        visit review_timeline_event_path(target_l2_2.timeline_events.last)
        click_button "Start Review"
        within("div#is_acceptable") { click_button "No" }
        click_button "Reject Submission"

        # No issued certificates, still.
        expect(IssuedCertificate.count).to eq(0)

        # Undo the grading and set a pass grade.
        accept_confirm { click_button("Undo Rejection") }
        click_button "Start Review"
        click_button "Good"
        click_button "Save grades"

        expect(page).to have_text("Evaluated By")
        expect(target_l2_2.timeline_events.last.reload.passed_at).to_not eq(nil)

        # Both students should now have a now certificate.
        expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(
          student_1.user.id,
          student_2.user.id
        )
      end
    end
  end

  context "when the milestone is completed individually" do
    let!(:target_l2) do
      create :target,
             :with_markdown,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             given_milestone_number: 2,
             target_group: target_group_l2,
             title: "foo"
    end

    scenario "each student completes the last target" do
      complete_milestone(target_l1)

      visit target_path(target_l2)

      find(".course-overlay__body-tab-item", text: "Submit Form").click
      replace_markdown Faker::Lorem.sentence
      click_button "Submit"

      expect(page).to have_content("Your response has been saved")

      # No certificate should be issued, yet.
      expect(IssuedCertificate.count).to eq(0)

      sign_in_user student_2.user, referrer: target_path(target_l2)

      find(".course-overlay__body-tab-item", text: "Submit Form").click
      replace_markdown Faker::Lorem.sentence
      click_button "Submit"

      visit curriculum_course_path(course)

      expect(page).to have_text(
        "Congratulations! You have completed all milestones in the course."
      )

      # Both students get certificate when the last student in team completes the target.
      expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(
        student_1.user.id,
        student_2.user.id
      )
    end
  end

  context "when there is no active certificate" do
    let!(:certificate) { create :certificate, course: course }

    scenario "students never receive certificates upon completion" do
      complete_milestone(target_l1)

      visit target_path(target_l2)

      find(".course-overlay__body-tab-item", text: "Submit Form").click
      replace_markdown Faker::Lorem.sentence
      click_button "Submit"

      # An active certificate is necessary for the automatic issuance of certificates.
      expect(IssuedCertificate.count).to eq(0)
    end
  end

  context "when there are no milestones" do
    let!(:target_l1) do
      create :target,
             :with_markdown,
             :with_shared_assignment,
             given_role: Assignment::ROLE_TEAM,
             target_group: target_group_l1
    end

    let!(:target_l2) do
      create :target,
             :with_markdown,
             :with_shared_assignment,
             given_role: Assignment::ROLE_TEAM,
             target_group: target_group_l2
    end

    scenario "students never receive certificates" do
      complete_milestone(target_l1)

      visit target_path(target_l2)

      find(".course-overlay__body-tab-item", text: "Submit Form").click
      replace_markdown Faker::Lorem.sentence
      click_button "Submit"

      # At least one milestone is required for the issuance of certificates.
      expect(IssuedCertificate.count).to eq(0)
    end
  end

  context "when there are no milestone for level 2" do
    let!(:target_l2) do
      create :target,
             :with_markdown,
             :with_shared_assignment,
             given_role: Assignment::ROLE_TEAM,
             target_group: target_group_l2
    end

    scenario "students receive certificate whenver all milestones are completed" do
      sign_in_user student_1.user, referrer: target_path(target_l1)

      find(".course-overlay__body-tab-item", text: "Submit Form").click
      replace_markdown Faker::Lorem.sentence
      click_button "Submit"

      dismiss_notification
      click_button "Close"

      # Certificate is issued whenever all milestones are completed
      expect(student_1.user.issued_certificates.count).to eq(1)

      sign_in_user student_1.user, referrer: target_path(target_l2)

      find(".course-overlay__body-tab-item", text: "Submit Form").click
      replace_markdown Faker::Lorem.sentence
      click_button "Submit"
      expect(page).to have_content("Your response has been saved")

      # Completing a non-milestone assignment in level 2 makes no difference
      expect(student_1.user.issued_certificates.count).to eq(1)
    end
  end

  context "when a certificate has already been issued" do
    let(:evaluation_criterion) { create :evaluation_criterion, course: course }

    let!(:target_l2) do
      create :target,
             :with_markdown,
             :with_shared_assignment,
             target_group: target_group_l2,
             given_milestone_number: 2,
             given_evaluation_criteria: [evaluation_criterion],
             given_role: Assignment::ROLE_TEAM
    end

    let(:coach) { create :faculty }

    scenario "student resubmits the final target" do
      # Enroll the coach in the cohort.
      create :faculty_cohort_enrollment, faculty: coach, cohort: cohort

      # Student 1 completes both targets.
      complete_target target_l1, student_1
      complete_target target_l2, student_1

      # Both students get issued certificates.
      create :issued_certificate, user: student_1.user, certificate: certificate
      create :issued_certificate, user: student_2.user, certificate: certificate

      # Student 2 resubmits the target...
      resubmission = submit_target target_l2, student_2

      sign_in_user coach.user,
                   referrer: review_timeline_event_path(resubmission)

      click_button "Start Review"
      click_button "Good"
      click_button "Save grades"

      expect(page).to have_text("Evaluated By")

      # It shouldn't issue duplicate certificates.
      expect(IssuedCertificate.count).to eq(2)
    end
  end
end
