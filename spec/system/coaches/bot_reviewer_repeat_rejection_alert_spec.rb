require "rails_helper"

feature "Alert coaches when a bot user repeatedly rejects submissions",
        js: true do
  include UserSpecHelper
  include NotificationHelper
  include SubmissionsHelper
  include ConfigHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:student) { create :student, cohort: cohort }
  let(:coach) { create :faculty, school: school }
  let(:bot_reviewer) { create :faculty, school: school }

  let(:grade_labels) do
    [{ "grade" => 1, "label" => "Okay" }, { "grade" => 2, "label" => "Accept" }]
  end

  let(:evaluation_criterion) do
    create :evaluation_criterion,
           course: course,
           max_grade: 2,
           grade_labels: grade_labels
  end

  let(:target) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group,
           given_evaluation_criteria: [evaluation_criterion]
  end

  around do |example|
    with_secret(
      bot: Config::Options.new({
        evaluator_ids: [bot_reviewer.id],
        evaluator_repeat_rejection_alert_threshold: 3
      })
    ) { example.run }
  end

  let!(:submission_rejected_1) do
    fail_target(target, student, evaluator: bot_reviewer, latest: false)
  end

  let(:submission_pending) do
    create(
      :timeline_event,
      :with_owners,
      owners: [student],
      latest: true,
      target: target
    )
  end

  before do
    create :faculty_cohort_enrollment, faculty: coach, cohort: cohort
    create :faculty_cohort_enrollment, faculty: bot_reviewer, cohort: cohort
  end

  context "with one submission rejected by the bot, and another pending review" do
    scenario "penultimate rejected submission should not generate an alert email" do
      sign_in_user bot_reviewer.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button "Start Review"
      within("div#is_acceptable") { click_button "No" }
      click_button "Reject Submission"

      open_email(coach.email)

      expect(current_email).to be_blank
    end
  end

  context "with two submissions rejected by the bot, and one pending review" do
    let!(:submission_rejected_2) do
      fail_target(target, student, evaluator: bot_reviewer, latest: false)
    end

    scenario "rejection of threshold number of submissions generates an alert email to other coaches" do
      sign_in_user bot_reviewer.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button "Start Review"
      within("div#is_acceptable") { click_button "No" }
      click_button "Reject Submission"
      expect(page).to have_content("Submission Rejected")

      expect(page).to have_content("Submission Rejected")
      expect(submission_pending.reload.evaluated_at).to_not eq(nil)

      open_email(coach.email)

      expect(current_email.subject).to eq(
        "Repeated rejection of a student's submission (3 times)"
      )
    end
  end

  context "with two submissions rejected by a human coach, and one pending review" do
    let!(:submission_rejected_1) do
      fail_target(target, student, evaluator: coach, latest: false)
    end

    let!(:submission_rejected_2) do
      fail_target(target, student, evaluator: coach, latest: false)
    end

    scenario "rejection of threshold number of submissions does not generate an alert email to other coaches" do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button "Start Review"
      within("div#is_acceptable") { click_button "No" }
      click_button "Reject Submission"

      expect(page).to have_content("Submission Rejected")
      expect(submission_pending.reload.evaluated_at).to_not eq(nil)

      open_email(coach.email)

      expect(current_email).to be_blank
    end
  end
end
