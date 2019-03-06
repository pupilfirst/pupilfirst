require 'rails_helper'

feature 'Target Overlay' do
  # TODO: Rewrite a cleaner version
  include UserSpecHelper

  let(:course) { create :course }
  let(:criterion) { create :evaluation_criterion, course: course }
  let!(:level_1) { create :level, :one, course: course }
  let!(:startup) { create :startup, level: level_1 }
  let!(:founder) { startup.founders.first }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true }
  let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:prerequisite_target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:timeline_event) { create :timeline_event, founders: startup.founders, passed_at: 2.days.ago, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }], latest: true }
  let!(:timeline_event_file) { create :timeline_event_file, timeline_event: timeline_event }
  let(:faculty) { create :faculty, slack_username: 'abcd' }
  let!(:feedback) { create :startup_feedback, timeline_event: timeline_event, startup: startup, faculty: faculty }
  let!(:resource_file) { create :resource, targets: [target] }
  let!(:resource_video_file) { create :resource_video_file, targets: [target] }
  let!(:resource_video_embed) { create :resource_video_embed, targets: [target] }
  let!(:resource_link) { create :resource_link, targets: [target] }

  # Quiz target
  let!(:quiz_target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:quiz) { create :quiz, target: quiz_target }
  let!(:quiz_question_1) { create :quiz_question, quiz: quiz }
  let!(:q1_answer_1) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:q1_answer_2) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:quiz_question_2) { create :quiz_question, quiz: quiz }
  let!(:q2_answer_1) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_2) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_3) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_4) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:quiz_question_3) { create :quiz_question, quiz: quiz }
  let!(:q3_answer_1) { create :answer_option, quiz_question: quiz_question_3 }
  let!(:q3_answer_2) { create :answer_option, quiz_question: quiz_question_3 }

  before do
    target.evaluation_criteria << criterion
    quiz_question_1.update!(correct_answer: q1_answer_2)
    quiz_question_2.update!(correct_answer: q2_answer_4)
    quiz_question_3.update!(correct_answer: q3_answer_1)
    founder.update!(dashboard_toured: true)
    sign_in_user founder.user, referer: student_dashboard_path
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
      expect(page).to have_current_path("/student/dashboard/targets/#{target.id}")

      ## Ensure different components of the overlay display the appropriate details.

      # Within the header:
      within('.target-overlay__header') do
        expect(page).to have_selector('.target-overlay-header__headline', text: target.title)
      end

      # Within the status badge bar:
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-clock-o')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > div > span', text: 'Pending')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'Follow completion instructions and submit!')
      end

      # Test the submit button.
      expect(page).to_not have_selector('.timeline-builder__popup-body')
      find('.target-overlay__status-badge-block').find('button.btn-timeline-builder').click
      expect(page).to have_selector('.timeline-builder__popup-body')
      find('.timeline-builder__modal-close').click # close the timeline builder.

      # Within the content block:
      within('.target-overlay-content-block') do
        expect(page).to have_selector('.target-overlay-content-block__header', text: 'Description')
        expect(page).to have_selector('.target-overlay-content-block__body--description', text: target.description)

        # Check resource links
        expect(page).to have_content('Library Links')
        expect(page).to have_link(resource_file.title.to_s, href: "/library/#{resource_file.slug}/download")
        expect(page).to have_link(resource_video_file.title.to_s, href: "/library/#{resource_video_file.slug}?watch=true")
        expect(page).to have_link(resource_video_embed.title.to_s, href: "/library/#{resource_video_embed.slug}?watch=true")
        expect(page).to have_link(resource_link.title.to_s, href: "/library/#{resource_link.slug}/download")
      end

      # Within the faculty box:
      within('.target-overlay__faculty-box') do
        expect(page).to have_text("Assigned by:\n#{target.faculty.name}")
        expect(page).to have_selector('.target-overlay__faculty-avatar > img')
      end
    end

    context 'when the target is auto verified' do
      let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_TEAM }

      before do
        target.target_evaluation_criteria.delete_all
        visit student_dashboard_path
      end

      it 'displays submit button with correct label' do
        find('.founder-dashboard-target-header__headline', text: target.title).click

        # The submit button has 'Mark Complete' label
        expect(page).to have_selector('button.btn-timeline-builder > span', text: 'MARK COMPLETE')
      end
    end
  end

  context 'when the founder clicks on a completed target', js: true do
    let!(:timeline_event) { create :timeline_event, target: target, founders: startup.founders, passed_at: 2.days.ago, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }], latest: true }

    it 'displays the latest submission and feedback for it' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      # Within the timeline event panel:
      within('.target-overlay-timeline-event-panel__container') do
        expect(page).to have_selector('.target-overlay-timeline-event-panel__title', text: 'Latest Timeline Submission:')
        expect(page).to have_selector('.target-overlay-timeline-event-panel__header-title', text: timeline_event.title)
        month_name = timeline_event.created_at.strftime('%b').upcase
        expect(page).to have_selector('.target-overlay-timeline-event-panel__header-date', text: month_name)
        date = "#{timeline_event.created_at.strftime('%e').strip}/#{timeline_event.created_at.strftime('%y')}"
        expect(page).to have_selector('.target-overlay-timeline-event-panel__header-date--large', text: date)
        expect(page).to have_selector('.target-overlay-timeline-event-panel__content', text: timeline_event.description)

        # Attachments.
        expect(page).to have_selector("a[href='https://www.example.com'] > .target-overlay__link--attachment-text", text: 'Some Link')

        tef_path = Rails.application.routes.url_helpers.download_timeline_event_file_path(timeline_event_file)
        expect(page).to have_selector("a[href='#{tef_path}'] > .target-overlay__link--attachment-text", text: timeline_event_file.title)

        # Latest Feedback.
        expect(page).to have_selector('.target-overlay-timeline-event-panel__feedback > p', text: feedback.feedback)
        expect(page).to have_selector('.target-overlay-timeline-event-panel__feedback > div > span > img')
        expect(page).to have_selector('.target-overlay-timeline-event-panel__feedback > div > h6 > span', text: faculty.name)

        # Slack connect button.
        expect(page).to have_selector('a[href=\'https://svlabs-public.slack.com/messages/@abcd\']', text: 'Discuss On Slack')
      end
    end
  end

  context 'when the founder clicks a founder target', js: true do
    let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_FOUNDER }
    let!(:timeline_event) { create :timeline_event, target: target, founders: [founder], passed_at: 2.days.ago, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }], latest: true }

    before do
      timeline_event.founders << founder
      visit student_dashboard_path
    end

    it 'displays the status for each founder' do
      find('.founder-dashboard-target-header__headline', text: target.title).click

      within('.target-overlay__content-rightbar') do
        expect(page).to have_selector('.target-overlay__status-title', text: 'Pending Team Members')
        expect(page).to have_selector('.founder-dashboard__avatar-wrapper', count: 1)
      end
    end
  end

  context 'when the founder clicks a locked target', js: true do
    context 'when the target has prerequisites' do
      before do
        target.prerequisite_targets << prerequisite_target
        visit student_dashboard_path
      end

      it 'informs about the pending prerequisite' do
        find('.founder-dashboard-target-header__headline', text: target.title).click

        # The target must be marked locked.
        within('.target-overlay__status-badge-block') do
          expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-lock')
          expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > div > span', text: 'Locked')
          expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'Complete the prerequisites first')
        end

        within('.target-overlay-content-block') do
          expect(page).to have_selector('.target-overlay-content-block__prerequisites > h6', text: 'Pending Prerequisites:')
          expect(page).to have_selector(".target-overlay-content-block__prerequisites-list-item > a[href='/student/dashboard/targets/#{prerequisite_target.id}']", text: prerequisite_target.title)
        end
      end
    end
  end

  context 'when the founder submits a new timeline event', js: true do
    it 'changes the status to submitted right away' do
      find('.founder-dashboard-target-header__headline', text: target.title).click
      # The target must be pending.
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-clock-o')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > div > span', text: 'Pending')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'Follow completion instructions and submit!')
      end

      find('.target-overlay__status-badge-block').find('button.btn-timeline-builder').click
      expect(page).to have_selector('.timeline-builder__popup-body')
      find('.timeline-builder__textarea').set('Some description')
      find('.js-timeline-builder__submit-button').click

      # The target status badge must now say submitted.
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-hourglass-half')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > div > span', text: 'Submitted')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: "Submitted on #{Date.today.strftime('%b %-e')}")
      end
    end
  end

  context 'when the founder submits a quiz target', js: true do
    it 'changes the status to completed right away' do
      find('.founder-dashboard-target-header__headline', text: quiz_target.title).click

      # The target must be pending.
      expect(page).to have_content('Pending')
      expect(page).to have_content('Follow completion instructions and submit!')

      click_button('Take Quiz')

      # Question one
      find('.quiz-root__answer-option', text: q1_answer_1.value).click
      expect(page).to have_content('Wrong Answer')
      find('.quiz-root__answer-option', text: q1_answer_2.value).click
      expect(page).to have_content('Correct Answer')
      click_button('Next')

      # Question two
      find('.quiz-root__answer-option', text: q2_answer_3.value).click
      expect(page).to have_content('Wrong Answer')
      find('.quiz-root__answer-option', text: q2_answer_4.value).click
      expect(page).to have_content('Correct Answer')
      click_button('Next')

      # Question three
      find('.quiz-root__answer-option', text: q3_answer_2.value).click
      expect(page).to have_content('Wrong Answer')
      find('.quiz-root__answer-option', text: q3_answer_1.value).click
      expect(page).to have_content('Correct Answer')

      # Submit Quiz
      click_button('Submit Quiz')

      expect(page).to have_content("Passed on #{Date.today.strftime('%b %-e')}")
    end
  end

  context 'when the founder clicks the back button from the overlay', js: true do
    it 'takes him/her back to the dashboard' do
      find('.founder-dashboard-target-header__headline', text: target.title).click
      expect(page).to have_selector('.target-overlay__overlay')
      expect(page).to have_current_path("/student/dashboard/targets/#{target.id}")

      find('.target-overlay__overlay-close-icon').click

      # Founder must now be on the dashboard.
      expect(page).to_not have_selector('.target-overlay__overlay')
      expect(page).to have_selector('.founder-dashboard-target-group__container')
      expect(page).to have_current_path('/student/dashboard')
    end
  end

  context 'when the course, the founder belongs has ended', js: true do
    before do
      course.update!(ends_at: 2.days.ago)
      visit student_dashboard_path
    end
    it 'shows appropriate notice that the course has ended' do
      find('.founder-dashboard-target-header__headline', text: target.title).click
      expect(page).to_not have_selector('.btn-timeline-builder')
    end
  end
end
