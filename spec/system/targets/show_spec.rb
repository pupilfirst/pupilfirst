require 'rails_helper'

feature 'Target Overlay' do
  include UserSpecHelper

  let(:course) { create :course }
  let(:criterion) { create :evaluation_criterion, course: course }
  let!(:level_1) { create :level, :one, course: course }
  let!(:team) { create :startup, level: level_1 }
  let!(:student) { team.founders.first }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true }
  let!(:target) { create :target, :with_content, target_group: target_group_1, role: Target::ROLE_TEAM, evaluation_criteria: [criterion] }
  let!(:prerequisite_target) { create :target, :with_content, target_group: target_group_1, role: Target::ROLE_TEAM }
  let!(:timeline_event) { create :timeline_event, founders: team.founders, passed_at: 2.days.ago, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }], latest: true }
  let!(:timeline_event_file) { create :timeline_event_file, timeline_event: timeline_event }
  let(:faculty) { create :faculty, slack_username: 'abcd' }
  let!(:feedback) { create :startup_feedback, timeline_event: timeline_event, startup: team, faculty: faculty }
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
    # Set correct answers for all quiz questions.
    quiz_question_1.update!(correct_answer: q1_answer_2)
    quiz_question_2.update!(correct_answer: q2_answer_4)
    quiz_question_3.update!(correct_answer: q3_answer_1)
  end

  context 'when the student selects a pending target', js: true do
    it 'displays the target overlay with all target details' do
      sign_in_user student.user, referer: course_path(course)

      # The target should be listed as part of the curriculum.
      expect(page).to have_content(target_group_1.name)
      expect(page).to have_content(target_group_1.description)
      expect(page).to have_content(target.title)

      # Click on the target.
      find("div[aria-label='Select Target #{target.id}'").click

      # The overlay should now be visible.
      expect(page).to have_selector('.course-overlay__body-tab-item')

      # And the page path must have changed.
      expect(page).to have_current_path("/targets/#{target.id}")

      ## Ensure different components of the overlay display the appropriate details.

      # Header should have the title and the status of the current status of the target.
      within('.course-overlay__header-title-card') do
        expect(page).to have_content(target.title)
        expect(page).to have_content('Pending')
      end

      # Learning content should include an embed, a markdown block, an image, and a file to download.
      expect(page).to have_selector('.learn-content-block__embed')
      expect(page).to have_selector('.markdown-block')
      image_caption = target.content_blocks.find_by(block_type: ContentBlock::BLOCK_TYPE_IMAGE).content['caption']
      expect(page).to have_content(image_caption)
      file_title = target.content_blocks.find_by(block_type: ContentBlock::BLOCK_TYPE_FILE).content['title']
      expect(page).to have_link(file_title)

      # This target should have a 'Complete' section.
      find('.course-overlay__body-tab-item', text: 'Complete').click

      # The user should be able to write text as description and attach upto three links and / or files.
      fill_in 'Work on your submission', with: Faker::Lorem.paragraph

      find('a', text: 'Add URL').click
      fill_in 'attachment_url', with: 'foobar'
      expect(page).to have_content('does not look like a valid URL')
      fill_in 'attachment_url', with: 'https://example.com?q=1'
      click_button 'Attach link'

      find('a', text: 'Upload File').click
      attach_file 'attachment_file', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'human.png')), visible: false
      expect(page).to have_selector('.course-show-attachments__attachment-title', text: 'human.png')

      find('a', text: 'Add URL').click
      expect(page).to have_selector('.course-show-attachments__attachment-title', text: 'https://example.com?q=1')
      fill_in 'attachment_url', with: 'https://example.com?q=2'
      click_button 'Attach link'
      expect(page).to have_selector('.course-show-attachments__attachment-title', text: 'https://example.com?q=2')

      # The attachment forms should have disappeared now.
      expect(page).not_to have_selector('a', text: 'Add URL')
      expect(page).not_to have_selector('a', text: 'Upload File')

      find('button', text: 'Submit').click

      expect(page).to have_content('Your submission has been queued for review')

      # The state of the target should change.
      within('.course-overlay__header-title-card') do
        expect(page).to have_content('Submitted')
      end
    end

    context 'when the target is auto verified' do
      let!(:target) { create :target, :with_content, target_group: target_group_1, role: Target::ROLE_TEAM }

      it 'displays submit button with correct label' do
        sign_in_user student.user, referer: target_path(target)

        # There should be a mark as complete button on the learn page.
        expect(page).to have_button('Mark As Complete')

        # The complete button should not be highlighted.
        expect(page).not_to have_selector('.complete-button-selected')

        # Clicking the mark as complete tab option should highlight the button.
        find('.course-overlay__body-tab-item', text: 'Mark as Complete').click
        expect(page).to have_selector('.complete-button-selected')
      end
    end
  end

  context 'when the student clicks on a completed target', js: true do
    let!(:timeline_event) { create :timeline_event, target: target, founders: team.founders, passed_at: 2.days.ago, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }], latest: true }

    it 'displays the latest submission and feedback for it' do
      sign_in_user student.user, referer: target_path(target)

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

  context 'when the student clicks an individual target', js: true do
    let!(:target) { create :target, target_group: target_group_1, days_to_complete: 60, role: Target::ROLE_FOUNDER }
    let!(:timeline_event) { create :timeline_event, target: target, founders: [student], passed_at: 2.days.ago, links: [{ title: 'Some Link', url: 'https://www.example.com', private: false }], latest: true }

    before do
      timeline_event.founders << student
    end

    it 'displays the status for each student' do
      sign_in_user student.user, referer: student_dashboard_path

      find('.founder-dashboard-target-header__headline', text: target.title).click

      within('.target-overlay__content-rightbar') do
        expect(page).to have_selector('.target-overlay__status-title', text: 'Pending Team Members')
        expect(page).to have_selector('.founder-dashboard__avatar-wrapper', count: 1)
      end
    end
  end

  context 'when the student clicks a locked target', js: true do
    context 'when the target has prerequisites' do
      before do
        target.prerequisite_targets << prerequisite_target
      end

      it 'informs about the pending prerequisite' do
        sign_in_user student.user, referer: student_dashboard_path

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

  context 'when the student submits anew', js: true do
    let(:bad_description) { 'Sum deskripshun. Oops. Typoos aplenty.' }

    it 'changes the status to submitted right away, and can be un-done' do
      sign_in_user student.user, referer: student_dashboard_path

      find('.founder-dashboard-target-header__headline', text: target.title).click

      # The target must be pending.
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-clock-o')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > div > span', text: 'Pending')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: 'Follow instructions to complete this target!')
      end

      find('.target-overlay__status-badge-block').find('button.btn-timeline-builder').click
      expect(page).to have_selector('.timeline-builder__popup-body')
      find('.timeline-builder__textarea').set(bad_description)
      find('.js-timeline-builder__submit-button').click

      # The target status badge must now say submitted.
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-icon > i.fa-hourglass-half')
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > div > span', text: 'Submitted')
        expect(page).to have_selector('.target-overlay-status-badge-bar__hint', text: "Submitted on #{Date.today.strftime('%b %-e')}")
      end

      last_timeline_event = target.timeline_events.joins(:founders).where(founders: { id: student }).last

      expect(last_timeline_event.description).to eq(bad_description)

      # The submission can be un-done.
      click_button('Undo')

      # The target must be set to pending.
      within('.target-overlay__status-badge-block') do
        expect(page).to have_selector('.target-overlay-status-badge-bar__badge-content > div > span', text: 'Pending')
      end

      # The submission should have been deleted.
      expect(TimelineEvent.find_by(id: last_timeline_event.id)).to eq(nil)
    end
  end

  context 'when the student submits a quiz target', js: true do
    it 'changes the status to completed right away' do
      sign_in_user student.user, referer: student_dashboard_path

      find('.founder-dashboard-target-header__headline', text: quiz_target.title).click

      # The target must be pending.
      expect(page).to have_content('Pending')
      expect(page).to have_content('Follow instructions to complete this target!')

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

  context 'when the student clicks the back button from the overlay', js: true do
    it 'takes him/her back to the dashboard' do
      sign_in_user student.user, referer: student_dashboard_path

      find('.founder-dashboard-target-header__headline', text: target.title).click
      expect(page).to have_selector('.target-overlay__overlay')
      expect(page).to have_current_path("/student/dashboard/targets/#{target.id}")

      find('.target-overlay__overlay-close-icon').click

      # student must now be on the dashboard.
      expect(page).to_not have_selector('.target-overlay__overlay')
      expect(page).to have_selector('.founder-dashboard-target-group__container')
      expect(page).to have_current_path('/student/dashboard')
    end
  end

  context 'when the course, the student belongs has ended', js: true do
    before do
      course.update!(ends_at: 2.days.ago)
    end

    it 'shows appropriate notice that the course has ended' do
      sign_in_user student.user, referer: student_dashboard_path
      find('.founder-dashboard-target-header__headline', text: target.title).click
      expect(page).to_not have_selector('.btn-timeline-builder')
    end
  end

  context 'when there is a target with a link_to_visit' do
    let(:link_to_complete) { "https://www.example.com/#{Faker::Lorem.word}" }
    let!(:target_with_link) { create :target, target_group: target_group_1, link_to_complete: link_to_complete }

    scenario 'student clicks visit on a target with a link to complete', js: true do
      sign_in_user student.user, referer: student_dashboard_target_path(target_with_link)

      click_button 'Visit'

      expect(page).to have_content('Redirecting you to the link now')

      # User should be redirected to the link_to_visit eventually.
      expect(page).to have_current_path(link_to_complete, url: true)

      # Target should now be complete for the user.
      expect(target_with_link.status(student)).to eq(Targets::StatusService::STATUS_PASSED)
    end
  end
end
