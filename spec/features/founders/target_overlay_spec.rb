require 'rails_helper'

feature 'Target Overlay' do
  include UserSpecHelper

  let!(:level_1) { create :level, :one }
  let!(:startup) { create :startup, :subscription_active, level: level_1 }
  let!(:founder) { startup.admin }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true }
  let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:prerequisite_target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:timeline_event) { create :timeline_event, startup: startup, founder: founder, iteration: startup.iteration, status: TimelineEvent::STATUS_VERIFIED, links: [{ 'title' => 'Some Link', 'url' => 'https://www.example.com', 'private' => false }] }
  let!(:timeline_event_file) { create :timeline_event_file, timeline_event: timeline_event }
  let(:faculty) { create :faculty, slack_username: 'abcd' }
  let!(:feedback) { create :startup_feedback, timeline_event: timeline_event, startup: startup, faculty: faculty }

  before do
    founder.update!(dashboard_toured: true)
    sign_in_user founder.user, referer: dashboard_founder_path
  end

  context 'when the founder clicks on a pending target', js: true do
    it 'displays the target overlay with all target details' do
      # The target should be listed on the dashboard.
      expect(page).to have_selector('.founder-dashboard-target-header__headline', text: target.title)
      # The dashboard should not have an overlay yet.
      expect(page).to_not have_selector('.target-overlay__overlay')

      # Click on the target.
      find('.founder-dashboard-target-header__headline', text: target.title).click
      # The overlay should now be visible.
      expect(page).to have_selector('.target-overlay__overlay')
      # And the page path must have changed
      expect(page).to have_current_path("/founder/dashboard/targets/#{target.id}")

      ## Ensure different components of the overlay display the appropriate details.

      # Close the pnotify first.
      find('.ui-pnotify').hover
      find('.ui-pnotify-closer').click

      # Within the header:
      within('.target-overlay__header') do
        expect(page).to have_selector('.target-overlay-header__headline', text: "Team Target:#{target.title}")
        expect(page).to have_selector('.target-overlay-header__info-subtext', text: 'Time required:60 days')
      end

      # Within the status badge bar:
      within('.target-overlay__status-badge__block') do
        expect(page).to have_selector('.target-overlay__status-badge-icon > i.fa-clock-o')
        expect(page).to have_selector('.target-overlay__status-badge-content > span', text: 'Pending')
        expect(page).to have_selector('.target-overlay__status-hint', text: 'Follow completion instructions and submit!')
      end

      # Test the submit button.
      expect(page).to_not have_selector('.timeline-builder__popup-body')
      find('.target-overlay__header').find('button.btn-timeline-builder').click
      expect(page).to have_selector('.timeline-builder__popup-body')
      find('.timeline-builder__modal-close').click # close the timeline builder.

      # Within the content block:
      within('.target-overlay-content-block') do
        expect(page).to have_selector('.target-overlay-content-block__header', text: 'Description')
        expect(page).to have_selector('.target-overlay-content-block__body--description', text: target.description)
      end

      # Within the assigner box:
      within('.target-overlay__assigner-box') do
        expect(page).to have_selector('.target-overlay__assigner-name > span', text: target.assigner.name)
        expect(page).to have_selector(".target-overlay__assigner-avatar > img[src='#{target.assigner.image_url}'")
      end
    end
  end

  context 'when the founder clicks on a completed target', js: true do
    before do
      timeline_event.update!(target: target)
    end

    it 'displays the latest submission and feedback for it' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      # Within the timeline event panel:
      within('.target-overlay-timeline-submission__container') do
        expect(page).to have_selector('.target-overlay-timeline-submission__title', text: 'Latest Timeline Submission:')
        expect(page).to have_selector('.target-overlay-timeline-submission__header-title > h5', text: timeline_event.title)
        month_name = timeline_event.event_on.strftime('%b').upcase
        expect(page).to have_selector('.target-overlay-timeline-submission__header-date', text: month_name)
        date = "#{timeline_event.event_on.strftime('%e').strip}/#{timeline_event.event_on.strftime('%y')}"
        expect(page).to have_selector('.target-overlay-timeline-submission__header-date--large', text: date)
        expect(page).to have_selector('.target-overlay-timeline-submission__header-title-date', text: 'Day 1')
        expect(page).to have_selector('.target-overlay-timeline-submission__content > p', text: timeline_event.description)

        # Attachments.
        expect(page).to have_selector("a[href='https://www.example.com'] > .target-overlay__link--attachment-text", text: 'Some Link')
        expect(page).to have_selector("a[href='#{timeline_event_file.file_url}'] > .target-overlay__link--attachment-text", text: timeline_event_file.title)

        # Latest Feedback.
        expect(page).to have_selector('.target-overlay-timeline-submission__feedback > p', text: feedback.feedback)
        expect(page).to have_selector(".target-overlay-timeline-submission__feedback > div > span > img[src='#{faculty.image_url}'")
        expect(page).to have_selector('.target-overlay-timeline-submission__feedback > div > h6 > span', text: faculty.name)

        # Slack connect button.
        expect(page).to have_selector('a[href=\'https://svlabs-public.slack.com/messages/@abcd\']', text: 'Discuss On Slack')
      end
    end
  end

  context 'when the founder clicks a founder target', js: true do
    before do
      target.update!(role: Target::ROLE_FOUNDER)
      timeline_event.update!(target: target)
      visit dashboard_founder_path
    end

    it 'displays the status for each founder' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      within('.target-overlay__rightbar') do
        expect(page).to have_selector('.target-overlay-timeline-submission__title', text: 'Completion Status')
        expect(page).to have_selector('.founder-dashboard__avatar-wrapper', count: 2)
        # TODO: Also check if the right people have the right status. This is now blocked by the bug reported here: https://trello.com/c/P9RNQQ3N
      end
    end
  end

  context 'when the founder clicks a locked target', js: true do
    before do
      target.prerequisite_targets << prerequisite_target
      visit dashboard_founder_path
    end

    it 'informs about the pending prerequisite' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      # The target must be marked locked.
      within('.target-overlay__status-badge__block') do
        expect(page).to have_selector('.target-overlay__status-badge-icon > i.fa-lock')
        expect(page).to have_selector('.target-overlay__status-badge-content > span', text: 'Locked')
        expect(page).to have_selector('.target-overlay__status-hint', text: 'Complete prerequisites first!')
      end

      within('.target-overlay-content-block') do
        expect(page).to have_selector('.target-overlay-content-block__prerequisites > h6', text: 'Pending Prerequisites:')
        expect(page).to have_selector(".target-overlay-content-block__prerequisites-list-item > a[href='/founder/dashboard/targets/#{prerequisite_target.id}']", text: prerequisite_target.title)
      end
    end
  end

  context 'when the founder submits a new timeline event', js: true do
    it 'changes the status to submitted right away' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      # The target must be pending.
      within('.target-overlay__status-badge__block') do
        expect(page).to have_selector('.target-overlay__status-badge-icon > i.fa-clock-o')
        expect(page).to have_selector('.target-overlay__status-badge-content > span', text: 'Pending')
        expect(page).to have_selector('.target-overlay__status-hint', text: 'Follow completion instructions and submit!')
      end

      find('.ui-pnotify').hover
      find('.ui-pnotify-closer').click

      find('.target-overlay__header').find('button.btn-timeline-builder').click
      expect(page).to have_selector('.timeline-builder__popup-body')
      find('.timeline-builder__textarea').set('Some description')
      find('.js-timeline-builder__submit-button').click

      # The target status badge must now say submitted.
      within('.target-overlay__status-badge__block') do
        expect(page).to have_selector('.target-overlay__status-badge-icon > i.fa-hourglass-half')
        expect(page).to have_selector('.target-overlay__status-badge-content > span', text: 'Submitted')
        expect(page).to have_selector('.target-overlay__status-hint', text: "Submitted on #{Date.today.strftime('%b %e')}")
      end
    end
  end

  context 'when the founder clicks the back button from the overlay', js: true do
    it 'takes him/her back to the dashboard' do
      find('.founder-dashboard-target-header__headline', text: target.title).click
      expect(page).to have_selector('.target-overlay__overlay')
      expect(page).to have_current_path("/founder/dashboard/targets/#{target.id}")

      find('.target-overlay__overlay-close-icon').click

      # Founder must now be on the dashboard.
      expect(page).to_not have_selector('.target-overlay__overlay')
      expect(page).to have_selector('.founder-dashboard-target-group__container')
      expect(page).to have_current_path('/founder/dashboard')
    end
  end
end
