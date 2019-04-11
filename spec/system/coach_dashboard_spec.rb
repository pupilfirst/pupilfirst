require 'rails_helper'
require 'rails_helper'

feature 'Coach Dashboard' do
  include UserSpecHelper

  # Setup a course with a single founder target, ...
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1 }
  let(:target) { create :target, :for_founders, target_group: target_group }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }

  # ... a couple of startups and a couch.
  let(:startup_1) { create :startup, level: level_1 }
  let(:startup_2) { create :startup, level: level_1 }
  let(:coach) { create :faculty, school: school }

  # Create a couple of pending timeline events for the startups.
  let!(:timeline_event_1) { create(:timeline_event, latest: true, target: target) }
  let!(:timeline_event_2) { create(:timeline_event, latest: true, target: target) }
  let!(:timeline_event_3) { create(:timeline_event, latest: true, target: target) }
  let!(:timeline_event_4) { create(:timeline_event, latest: true, target: target) }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course
    # create :faculty_startup_enrollment, faculty: coach, startup: startup_1
    # create :faculty_startup_enrollment, faculty: coach, startup: startup_2

    target.evaluation_criteria << evaluation_criterion
    timeline_event_1.founders << startup_1.founders.first
    timeline_event_2.founders << startup_1.founders.second
    timeline_event_3.founders << startup_2.founders.first
    timeline_event_4.founders << startup_2.founders.second

    # Create a domain for school.
    create :domain, :primary, school: school
  end

  scenario 'coach visits dashboard', js: true do
    sign_in_user coach.user, referer: course_coach_dashboard_path(course)

    # Ensure coach is on the dashboard.
    expect(page).to have_selector('.timeline-events-panel__status-tab', text: 'Pending')
    expect(page).to have_selector('.timeline-events-panel__status-tab-badge', text: '4')

    # All timeline events should be listed (excluding the auto-verified one)
    within('.timeline-events-list__container') do
      expect(page).to have_selector('.timeline-event-card__container', count: 4)
    end

    # The 'reviewed' tab should be empty
    find('.timeline-events-panel__status-tab', text: 'Reviewed').click
    expect(page).to have_selector('.timeline-events-panel__empty-notice', text: "When you review submissions, they'll be shown in this section")
  end

  scenario 'coach uses the sidebar filter', js: true do
    sign_in_user coach.user, referer: course_coach_dashboard_path(course)

    # Students should be listed properly on the sidebar.
    within('.founders-list__container') do
      expect(page).to have_selector('.founders-list__item', count: 5)
      expect(page).to have_selector('.founders-list__item', text: 'All students')
      expect(page).to have_selector('.founders-list__item', text: startup_1.founders.first.name)
      expect(page).to have_selector('.founders-list__item', text: startup_1.founders.second.name)
      expect(page).to have_selector('.founders-list__item', text: startup_2.founders.first.name)
      expect(page).to have_selector('.founders-list__item', text: startup_2.founders.second.name)

      # Search input should be filter the list of students.
      page.find('input').fill_in(with: startup_1.founders.first.name)

      expect(page).to have_selector('.founders-list__item', count: 2)
      expect(page).to have_selector('.founders-list__item', text: 'All students')
      expect(page).to have_selector('.founders-list__item', text: startup_1.founders.first.name)
      expect(page).not_to have_selector('.founders-list__item', text: startup_1.founders.second.name)
      expect(page).not_to have_selector('.founders-list__item', text: startup_2.founders.first.name)
      expect(page).not_to have_selector('.founders-list__item', text: startup_2.founders.second.name)
    end

    # Filter submissions by picking a student.
    find('.founders-list__item', text: startup_1.founders.first.name).click

    # the list should now be filtered correctly
    expect(page).to have_selector('.timeline-event-card__container', count: 1)
    expect(page).to have_selector('.timeline-event-card__description', text: timeline_event_1.description)
    expect(page).to_not have_selector('.timeline-event-card__description', text: timeline_event_2.description)
    expect(page).to_not have_selector('.timeline-event-card__description', text: timeline_event_3.description)
    expect(page).to_not have_selector('.timeline-event-card__description', text: timeline_event_4.description)

    # Clearing the filter should display all submissions again.
    find('.founders-list__item', text: 'All students').click

    expect(page).to have_selector('.timeline-event-card__container', count: 4)

    # The students listed on the sidebar should also have reverted to original.
    expect(page).to have_selector('.founders-list__item', text: startup_1.founders.first.name)
    expect(page).to have_selector('.founders-list__item', text: startup_1.founders.second.name)
    expect(page).to have_selector('.founders-list__item', text: startup_2.founders.first.name)
    expect(page).to have_selector('.founders-list__item', text: startup_2.founders.second.name)
  end

  scenario 'coach reviews a submission and then undo-s the review', js: true do
    sign_in_user coach.user, referer: course_coach_dashboard_path(course)

    # Grade the first event as 'Bad'.
    within(".timeline-event-card__container", text: timeline_event_1.description) do
      find('div[title="Bad"]').click
      click_button 'Save Grading'
    end

    # The event should have moved to the completed list.
    expect(page).to have_selector('.timeline-event-card__container', count: 3)

    # And the pending count updated to 3.
    within('.timeline-events-panel__status-tab--active') do
      expect(page).to have_content('Pending')
      expect(page).to have_content('3')
    end

    # Switch to the 'Reviewed' tab.
    find('.timeline-events-panel__status-tab', text: 'Reviewed').click

    # One submission should be displayed.
    expect(page).to have_selector('.timeline-event-card__container', count: 1)

    within('.timeline-event-card__container') do
      # The submission should have the failed status.
      expect(page).to have_content('Failed')

      # The submission should have the reviewer name.
      expect(page).to have_content(coach.name)

      # It should also list the selected grade for a criterion.
      expect(page).to have_content("#{evaluation_criterion.name}: Bad")
    end

    # The event should have the new status.
    expect(timeline_event_1.reload.passed_at).to eq(nil)
    expect(timeline_event_1.evaluator).to eq(coach)

    # Check the reviewed list after reloading the page. It should be empty.
    visit course_coach_dashboard_path(course)
    find('.timeline-events-panel__status-tab', text: 'Reviewed').click
    expect(page).not_to have_selector('.timeline-event-card__container', count: 1)

    # Load previously reviewed submissions.
    click_button 'Load earlier submissions'
    expect(page).to have_selector('.timeline-event-card__container', count: 1)

    # Undo the review.
    click_button 'Undo Review'

    # The event should have moved back to the 'Pending' list.
    expect(page).to have_content("When you review submissions, they'll be shown in this section.")
    find('.timeline-events-panel__status-tab', text: 'Pending').click
    expect(page).to have_selector('.timeline-event-card__container', count: 4)

    # Timeline event should be pending again.
    expect(timeline_event_1.reload.evaluator).to eq(nil)

    # ...and the pending count updated.
    within('.timeline-events-panel__status-tab--active') do
      expect(page).to have_content('Pending')
      expect(page).to have_content('4')
    end
  end

  scenario 'coach sends some feedback', js: true do
    sign_in_user coach.user, referer: course_coach_dashboard_path(course)

    within find(".timeline-event-card__container", match: :first) do
      # feedback form should be hidden by default
      expect(page).to_not have_selector('.feedback-form__trix-container')
      click_on 'Email Feedback'
      # the form should now be visible
      expect(page).to have_selector('.feedback-form__trix-container')
      click_on 'Cancel'
      # form hidden again
      expect(page).to_not have_selector('.feedback-form__trix-container')
      # Let's add a feedback
      click_on 'Email Feedback'
      find('trix-editor').click.set 'Some important feedback'
      click_on 'Send'
      # form should now be hidden
      expect(page).to_not have_selector('.feedback-form__trix-container')
      # and a feedback created for the event
      expect(StartupFeedback.last.feedback).to eq('<div>Some important feedback</div>')
    end
  end
end
