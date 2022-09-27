require 'rails_helper'

feature 'Alert coaches when a bot user repeatedly rejects submissions',
        js: true do
  include UserSpecHelper
  include NotificationHelper
  include SubmissionsHelper
  include ConfigHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }

  let(:evaluation_criterion) do
    create :evaluation_criterion,
           course: course,
           max_grade: 2,
           pass_grade: 2,
           grade_labels: grade_labels
  end

  let(:target) do
    create :target,
           :for_founders,
           target_group: target_group,
           evaluation_criteria: [evaluation_criterion]
  end

  let(:grade_labels) do
    [
      { 'grade' => 1, 'label' => 'Reject' },
      { 'grade' => 2, 'label' => 'Accept' }
    ]
  end

  let(:team) { create :startup, level: level }
  let(:coach) { create :faculty, school: school }
  let(:bot_reviewer) { create :faculty, school: school }

  around do |example|
    with_secret(
      bot: {
        evaluator_ids: [bot_reviewer.id],
        evaluator_repeat_rejection_alert_threshold: 3
      }
    ) { example.run }
  end

  let(:student) { team.founders.first }

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
    create :faculty_course_enrollment, faculty: coach, course: course
    create :faculty_course_enrollment, faculty: bot_reviewer, course: course
  end

  context 'with one submission rejected by the bot, and another pending review' do
    scenario 'penultimate rejected submission should not generate an alert email' do
      sign_in_user bot_reviewer.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button 'Start Review'

      dismiss_notification

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion.id}']"
      ) { find("button[title='Reject']").click }

      click_button 'Save grades'

      expect(page).to have_text('The submission has been marked as reviewed')

      open_email(coach.email)
      expect(current_email).to be_blank
    end
  end

  context 'with two submissions rejected by the bot, and one pending review' do
    let!(:submission_rejected_2) do
      fail_target(target, student, evaluator: bot_reviewer, latest: false)
    end

    scenario 'rejection of threshold number of submissions generates an alert email to other coaches' do
      sign_in_user bot_reviewer.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button 'Start Review'

      dismiss_notification

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion.id}']"
      ) { find("button[title='Reject']").click }

      click_button 'Save grades'

      expect(page).to have_text('The submission has been marked as reviewed')

      open_email(coach.email)

      expect(current_email.subject).to eq(
        "Repeated rejection of a student's submission (3 times)"
      )
    end
  end

  context 'with two submissions rejected by a human coach, and one pending review' do
    let!(:submission_rejected_1) do
      fail_target(target, student, evaluator: coach, latest: false)
    end

    let!(:submission_rejected_2) do
      fail_target(target, student, evaluator: coach, latest: false)
    end

    scenario 'rejection of threshold number of submissions does not generate an alert email to other coaches' do
      sign_in_user coach.user,
                   referrer: review_timeline_event_path(submission_pending)

      click_button 'Start Review'

      dismiss_notification

      within(
        "div[aria-label='evaluation-criterion-#{evaluation_criterion.id}']"
      ) { find("button[title='Reject']").click }

      click_button 'Save grades'

      expect(page).to have_text('The submission has been marked as reviewed')

      open_email(coach.email)

      expect(current_email).to be_blank
    end
  end
end
