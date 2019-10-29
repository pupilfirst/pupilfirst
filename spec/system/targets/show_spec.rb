require 'rails_helper'

feature 'Target Overlay', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  let(:course) { create :course }
  let!(:criterion_1) { create :evaluation_criterion, course: course }
  let!(:criterion_2) { create :evaluation_criterion, course: course }
  let!(:level_0) { create :level, :zero, course: course }
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:team) { create :startup, level: level_1 }
  let!(:student) { team.founders.first }
  let!(:target_group_l0) { create :target_group, level: level_0 }
  let!(:target_group_l1) { create :target_group, level: level_1, milestone: true }
  let!(:target_group_l2) { create :target_group, level: level_2 }
  let!(:target_l0) { create :target, target_group: target_group_l0 }
  let!(:target_l1) { create :target, :with_content, target_group: target_group_l1, role: Target::ROLE_TEAM, evaluation_criteria: [criterion_1, criterion_2], completion_instructions: Faker::Lorem.sentence }
  let!(:target_l2) { create :target, target_group: target_group_l2 }
  let!(:prerequisite_target) { create :target, :with_content, target_group: target_group_l1, role: Target::ROLE_TEAM }

  # Quiz target
  let!(:quiz_target) { create :target, target_group: target_group_l1, days_to_complete: 60, role: Target::ROLE_TEAM, resubmittable: false, completion_instructions: Faker::Lorem.sentence }
  let!(:quiz) { create :quiz, target: quiz_target }
  let!(:quiz_question_1) { create :quiz_question, quiz: quiz }
  let!(:q1_answer_1) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:q1_answer_2) { create :answer_option, quiz_question: quiz_question_1 }
  let!(:quiz_question_2) { create :quiz_question, quiz: quiz }
  let!(:q2_answer_1) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_2) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_3) { create :answer_option, quiz_question: quiz_question_2 }
  let!(:q2_answer_4) { create :answer_option, quiz_question: quiz_question_2 }

  before do
    # Set correct answers for all quiz questions.
    quiz_question_1.update!(correct_answer: q1_answer_2)
    quiz_question_2.update!(correct_answer: q2_answer_4)
  end

  scenario 'student selects a target to view its content' do
    sign_in_user student.user, referer: curriculum_course_path(course)

    # The target should be listed as part of the curriculum.
    expect(page).to have_content(target_group_l1.name)
    expect(page).to have_content(target_group_l1.description)
    expect(page).to have_content(target_l1.title)

    # Click on the target.
    find("div[aria-label='Select Target #{target_l1.id}'").click

    # The overlay should now be visible.
    expect(page).to have_selector('.course-overlay__body-tab-item')

    # And the page path must have changed.
    expect(page).to have_current_path("/targets/#{target_l1.id}")

    ## Ensure different components of the overlay display the appropriate details.

    # Header should have the title and the status of the current status of the target.
    within('.course-overlay__header-title-card') do
      expect(page).to have_content(target_l1.title)
      expect(page).to have_content('Pending')
    end

    # Learning content should include an embed, a markdown block, an image, and a file to download.
    expect(page).to have_selector('.learn-content-block__embed')
    expect(page).to have_selector('.markdown-block')
    content_blocks = ContentBlock.where(id: target_l1.latest_content_versions.pluck(:content_block_id))
    image_caption = content_blocks.find_by(block_type: ContentBlock::BLOCK_TYPE_IMAGE).content['caption']
    expect(page).to have_content(image_caption)
    file_title = content_blocks.find_by(block_type: ContentBlock::BLOCK_TYPE_FILE).content['title']
    expect(page).to have_link(file_title)
  end

  scenario 'student submits work on a target' do
    sign_in_user student.user, referer: target_path(target_l1)

    # This target should have a 'Complete' section.
    find('.course-overlay__body-tab-item', text: 'Complete').click
    # completion instructions should be show on complete section for evaluated targets
    expect(page).to have_text(target_l1.completion_instructions)
    bad_description = 'Sum deskripshun. Oops. Typoos aplenty.'
    link_1 = 'https://example.com?q=1'
    link_2 = 'https://example.com?q=2'

    # The submit button should be disabled at this point.
    expect(page).to have_button('Submit', disabled: true)

    # Filling in with a bunch of spaces should not work.
    fill_in 'Work on your submission', with: '   '
    expect(page).to have_button('Submit', disabled: true)

    # The user should be able to write text as description and attach upto three links and / or files.
    fill_in 'Work on your submission', with: bad_description

    # The submit button should be enabled now.
    expect(page).to have_button('Submit')

    find('a', text: 'Add URL').click
    fill_in 'attachment_url', with: 'foobar'
    expect(page).to have_content('does not look like a valid URL')
    fill_in 'attachment_url', with: 'https://example.com?q=1'

    # The submit button should be disabled when the link is being typed in.
    expect(page).not_to have_button('Submit')
    expect(page).to have_button('Finish adding link...', disabled: true)

    click_button 'Attach link'

    # The submit button should be enabled again now.
    expect(page).to have_button('Submit')

    find('a', text: 'Upload File').click
    attach_file 'attachment_file', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'human.png')), visible: false
    find('a', text: 'Add URL').click
    fill_in 'attachment_url', with: 'https://example.com?q=2'
    click_button 'Attach link'

    expect(page).to have_link('human.png', href: "/timeline_event_files/#{TimelineEventFile.last.id}/download")
    expect(page).to have_link(link_1, href: link_1)
    expect(page).to have_link(link_2, href: link_2)

    # The attachment forms should have disappeared now.
    expect(page).not_to have_selector('a', text: 'Add URL')
    expect(page).not_to have_selector('a', text: 'Upload File')

    find('button', text: 'Submit').click

    expect(page).to have_content('Your submission has been queued for review')

    # The state of the target should change.
    within('.course-overlay__header-title-card') do
      expect(page).to have_content('Submitted')
    end

    # The submissions should mention that review is pending.
    expect(page).to have_content('Review pending')

    # The student should be able to undo the submission at this point.
    expect(page).to have_button('Undo sumission')

    # User should be looking at their submission now.
    expect(page).to have_content('Your Submissions')

    # Let's check the database to make sure the submission was created correctly
    last_submission = TimelineEvent.last
    expect(last_submission.description).to eq(bad_description)
    expect(last_submission.links).to contain_exactly(link_1, link_2)
    expect(last_submission.timeline_event_files.first.file.filename).to eq('human.png')

    # The status should also be updated on the home page.
    click_button 'Close'

    within("div[aria-label='Select Target #{target_l1.id}'") do
      expect(page).to have_content('Submitted')
    end

    # Return to the submissions & feedback tab on the target overlay.
    find("div[aria-label='Select Target #{target_l1.id}'").click
    find('.course-overlay__body-tab-item', text: 'Submissions & Feedback').click

    # The submission contents should be on the page.
    expect(page).to have_content(bad_description)
    expect(page).to have_link('human.png', href: "/timeline_event_files/#{TimelineEventFile.last.id}/download")
    expect(page).to have_link(link_1, href: link_1)
    expect(page).to have_link(link_2, href: link_2)

    # User should be able to undo the submission.
    accept_confirm do
      click_button('Undo sumission')
    end

    # This action should reload the page and return the user to the content of the target.
    expect(page).to have_selector('.learn-content-block__embed')

    # The last submissions should have been deleted...
    expect { last_submission.reload }.to raise_exception(ActiveRecord::RecordNotFound)

    # ...and the complete section should be accessible again.
    expect(page).to have_selector('.course-overlay__body-tab-item', text: 'Complete')
  end

  context 'when the target is auto-verified' do
    let!(:target_l1) { create :target, :with_content, target_group: target_group_l1, role: Target::ROLE_TEAM, completion_instructions: Faker::Lorem.sentence }

    scenario 'student completes an auto-verified target' do
      sign_in_user student.user, referer: target_path(target_l1)

      # There should be a mark as complete button on the learn page.
      expect(page).to have_button('Mark As Complete')

      # Completion instructions should be show on learn section for auto-verified targets
      expect(page).to have_text("Before marking as complete")
      expect(page).to have_text(target_l1.completion_instructions)

      # The complete button should not be highlighted.
      expect(page).not_to have_selector('.complete-button-selected')

      # Clicking the mark as complete tab option should highlight the button.
      find('.course-overlay__body-tab-item', text: 'Mark as Complete').click
      expect(page).to have_selector('.complete-button-selected')

      click_button 'Mark As Complete'

      # The button should be replaced with a 'completed' marker.
      expect(page).to have_selector('.complete-button-selected', text: 'Completed')

      # The target should be marked as passed.
      expect(page).to have_selector('.course-overlay__header-title-card', text: 'Passed')

      # Target should have been marked as passed in the database.
      expect(target_l1.status(student)).to eq(Targets::StatusService::STATUS_PASSED)
    end

    context 'when the target requires student to visit a link to complete it' do
      let(:link_to_complete) { "https://www.example.com/#{Faker::Lorem.word}" }
      let!(:target_with_link) { create :target, target_group: target_group_l1, link_to_complete: link_to_complete, completion_instructions: Faker::Lorem.sentence }

      scenario 'student completes a target by visiting a link' do
        sign_in_user student.user, referer: target_path(target_with_link)

        # There should be a un-highligted button on the learn page that lets student complete the target.
        expect(page).to have_button('Visit Link To Complete')
        expect(page).not_to have_selector('.complete-button-selected')

        # Completion instructions should be show on learn section for targets with link to complete
        expect(page).to have_text("Before visiting the link")
        expect(page).to have_text(target_with_link.completion_instructions)

        # Clicking the tab should highlight the button.
        find('.course-overlay__body-tab-item', text: 'Visit Link to Complete').click
        expect(page).to have_selector('.complete-button-selected')

        # Clicking the button should complete the target and send the student to the link.
        new_window = window_opened_by { click_button 'Visit Link To Complete' }

        # User should be redirected to the link_to_visit.
        within_window new_window do
          expect(page).to have_current_path(link_to_complete, url: true)
          page.driver.browser.close
        end

        # Target should now be complete for the user.
        expect(page).to have_selector('.course-overlay__header-title-card', text: 'Passed')

        # Target should have been marked as passed in the database.
        expect(target_with_link.status(student)).to eq(Targets::StatusService::STATUS_PASSED)
      end
    end

    context 'when the target requires student to take a quiz to complete it ' do
      scenario 'student completes a target by taking a quiz' do
        sign_in_user student.user, referer: target_path(quiz_target)

        within('.course-overlay__header-title-card') do
          expect(page).to have_content(quiz_target.title)
          expect(page).to have_content('Pending')
        end

        find('.course-overlay__body-tab-item', text: 'Take Quiz').click

        # Completion instructions should be show on Take Quiz section for targets with quiz
        expect(page).to have_text("Instructions")
        expect(page).to have_text(quiz_target.completion_instructions)

        # Question one
        expect(page).to have_content(/Question #1/i)
        expect(page).to have_content(quiz_question_1.question)
        find('.quiz-root__answer', text: q1_answer_1.value).click
        click_button('Next Question')

        # Question two
        expect(page).to have_content(/Question #2/i)
        expect(page).to have_content(quiz_question_2.question)
        find('.quiz-root__answer', text: q2_answer_4.value).click
        click_button('Submit Quiz')

        expect(page).to have_content('Your Submission has been recorded')

        within('.course-overlay__header-title-card') do
          expect(page).to have_content(quiz_target.title)
          expect(page).to have_content('Passed')
        end

        # The quiz result should be visible.
        expect(page).to have_content("Target #{quiz_target.title} was completed by answering a quiz")
        expect(page).to have_content("Your Answer: #{q1_answer_1.value}")
        expect(page).to have_content("Correct Answer: #{q1_answer_2.value}")
        expect(page).to have_content("Your Correct Answer: #{q2_answer_4.value}")

        # The score should have stored on the submission.
        expect(TimelineEvent.last.quiz_score).to eq('1/2')
      end
    end
  end

  context 'when previous submissions exist, and has feedback' do
    let(:coach_1) { create :faculty, school: course.school }
    let(:coach_2) { create :faculty, school: course.school } # The 'unknown', un-enrolled coach.
    let(:coach_3) { create :faculty, school: course.school }
    let(:submission_1) { create :timeline_event, target: target_l1, founders: team.founders, evaluator: coach_1, links: ['https://www.example.com/broken_link'], created_at: 7.days.ago }
    let(:submission_2) { create :timeline_event, target: target_l1, founders: team.founders, evaluator: coach_3, passed_at: 2.days.ago, links: ['https://www.example.com/proper_link'], latest: true, created_at: 3.days.ago }
    let!(:attached_file) { create :timeline_event_file, timeline_event: submission_2 }
    let!(:feedback_1) { create :startup_feedback, timeline_event: submission_1, startup: team, faculty: coach_1 }
    let!(:feedback_2) { create :startup_feedback, timeline_event: submission_1, startup: team, faculty: coach_2 }
    let!(:feedback_3) { create :startup_feedback, timeline_event: submission_2, startup: team, faculty: coach_3 }

    before do
      # Enroll one of the coaches to course, and another to the team. One should be left un-enrolled to test how that's handled.
      create(:faculty_course_enrollment, faculty: coach_1, course: course)
      create(:faculty_startup_enrollment, faculty: coach_3, startup: team)

      # First submission should have failed on one criterion.
      create(:timeline_event_grade, timeline_event: submission_1, evaluation_criterion: criterion_1, grade: 2)
      create(:timeline_event_grade, timeline_event: submission_1, evaluation_criterion: criterion_2, grade: 1) # Failed criterion

      # Second submissions should have passed on both criteria.
      create(:timeline_event_grade, timeline_event: submission_2, evaluation_criterion: criterion_1, grade: 3)
      create(:timeline_event_grade, timeline_event: submission_2, evaluation_criterion: criterion_2, grade: 2)
    end

    scenario 'student sees feedback for a reviewed submission' do
      sign_in_user student.user, referer: target_path(target_l1)

      find('.course-overlay__body-tab-item', text: 'Submissions & Feedback').click

      # Both submissions should be visible, along with grading and all feedback from coaches.

      within("div[aria-label='Details about your submission on #{submission_1.created_at.strftime('%B %-d, %Y')}']") do
        expect(page).to have_content(submission_1.description)
        expect(page).to have_link('https://www.example.com/broken_link')

        expect(page).to have_content("#{criterion_1.name}: Good")
        expect(page).to have_content("#{criterion_2.name}: Bad")

        expect(page).to have_content(coach_1.name)
        expect(page).to have_content(coach_1.title)
        expect(page).to have_content(feedback_1.feedback)

        expect(page).not_to have_content(coach_2.name)
        expect(page).not_to have_content(coach_2.title)
        expect(page).to have_content("Unknown Coach")
        expect(page).to have_content(feedback_2.feedback)
      end

      within("div[aria-label='Details about your submission on #{submission_2.created_at.strftime('%B %-d, %Y')}']") do
        expect(page).to have_content(submission_2.description)
        expect(page).to have_link('https://www.example.com/proper_link')

        expect(page).to have_content("#{criterion_1.name}: Great")
        expect(page).to have_content("#{criterion_2.name}: Good")

        expect(page).to have_content(coach_3.name)
        expect(page).to have_content(coach_3.title)
        expect(page).to have_content(feedback_3.feedback)
      end

      # Adding another submissions should be possible.
      find('button', text: 'Add another submission').click

      expect(page).to have_content('Work on your submission')

      # There should be a cancel button to go back to viewing submissions.
      click_button 'Cancel'
      expect(page).to have_content(submission_1.description)
    end

    context 'when the target is non-resubmittable' do
      before do
        target_l1.update(resubmittable: false)
      end

      scenario 'student cannot resubmit non-resubmittable passed target' do
        sign_in_user student.user, referer: target_path(target_l1)

        find('.course-overlay__body-tab-item', text: 'Submissions & Feedback').click

        expect(page).not_to have_selector('button', text: 'Add another submission')
      end

      scenario 'student can resubmit non-resubmittable target if its failed' do
        # Make the first failed submission the latest, and the only one.
        submission_2.destroy!
        submission_1.update(latest: true)

        sign_in_user student.user, referer: target_path(target_l1)

        find('.course-overlay__body-tab-item', text: 'Submissions & Feedback').click

        expect(page).to have_selector('button', text: 'Add another submission')
      end
    end
  end

  context "when some team members haven't completed an individual target" do
    let!(:target_l1) { create :target, target_group: target_group_l1, role: Target::ROLE_FOUNDER }
    let!(:timeline_event) { create :timeline_event, target: target_l1, founders: [student], passed_at: 2.days.ago, latest: true }

    scenario 'student is shown pending team members on individual targets' do
      sign_in_user student.user, referer: target_path(target_l1)

      other_students = team.founders.where.not(id: student)

      # A safety check, in case factory is altered.
      expect(other_students.count).to be > 0

      expect(page).to have_content('You have team members who are yet to complete this target:')

      # The other students should also be listed.
      other_students.each do |other_student|
        expect(page).to have_selector("div[title='#{other_student.name} has not completed this target.']")
      end
    end
  end

  context 'when a pending target has prerequisites' do
    before do
      target_l1.prerequisite_targets << prerequisite_target
    end

    scenario 'student navigates to a prerequisite target' do
      sign_in_user student.user, referer: target_path(target_l1)

      within('.course-overlay__header-title-card') do
        expect(page).to have_content('Locked')
      end

      expect(page).to have_content('This target has pre-requisites that are incomplete.')

      # It should be possible to navigate to the prerequisite target.
      within('.course-overlay__prerequisite-targets') do
        find('span', text: prerequisite_target.title).click
      end

      within('.course-overlay__header-title-card') do
        expect(page).to have_content(prerequisite_target.title)
        expect(page).to have_content('Pending')
      end

      expect(page).to have_current_path("/targets/#{prerequisite_target.id}")
    end
  end

  context 'when the course has ended' do
    before do
      course.update!(ends_at: 1.day.ago)
    end

    scenario 'student visits a pending target' do
      sign_in_user student.user, referer: target_path(target_l1)

      within('.course-overlay__header-title-card') do
        expect(page).to have_content(target_l1.title)
        expect(page).to have_content('Locked')
      end

      expect(page).to have_content('The course has ended and submissions are disabled for all targets!')
      expect(page).not_to have_selector('.course-overlay__body-tab-item', text: 'Complete')
    end

    scenario 'student views a submitted target' do
      create :timeline_event, :latest, target: target_l1, founders: team.founders

      sign_in_user student.user, referer: target_path(target_l1)

      # The status should read locked.
      within('.course-overlay__header-title-card') do
        expect(page).to have_content(target_l1.title)
        expect(page).to have_content('Locked')
      end

      # The submissions & feedback sections should be visible.
      find('.course-overlay__body-tab-item', text: 'Submissions & Feedback').click

      # The submissions should mention that review is pending.
      expect(page).to have_content('Review pending')

      # The student should NOT be able to undo the submission at this point.
      expect(page).not_to have_button('Undo sumission')
    end
  end

  context "when student's access to course has ended" do
    before do
      team.update!(access_ends_at: 1.day.ago)
    end

    scenario 'student visits a target in a course where their access has ended' do
      sign_in_user student.user, referer: target_path(target_l1)

      within('.course-overlay__header-title-card') do
        expect(page).to have_content(target_l1.title)
        expect(page).to have_content('Locked')
      end

      expect(page).to have_content('Your access to this course has ended.')
      expect(page).not_to have_selector('.course-overlay__body-tab-item', text: 'Complete')
    end
  end

  context 'when the course has a community which accepts linked targets' do
    let!(:community_1) { create :community, :target_linkable, school: course.school, courses: [course] }
    let!(:community_2) { create :community, :target_linkable, school: course.school, courses: [course] }
    let!(:question_1) { create :question, community: community_1, creator: student.user }
    let!(:question_2) { create :question, community: community_1, creator: student.user }
    let(:question_title) { Faker::Lorem.sentence }
    let(:question_description) { Faker::Lorem.paragraph }

    scenario 'student uses the discuss feature' do
      sign_in_user student.user, referer: target_path(target_l1)

      # Overlay should have a discuss tab that lists linked communities.
      find('.course-overlay__body-tab-item', text: 'Discuss').click
      expect(page).to have_text(community_1.name)
      expect(page).to have_text(community_2.name)
      expect(page).to have_link("Go to community", count: 2)
      expect(page).to have_link("Ask a question", count: 2)
      expect(page).to have_text("There's been no recent discussion about this target.", count: 2)

      # Student can ask a question related to the target in community from target overlay.
      find("a[title='Ask a question in the #{community_1.name} community'").click

      expect(page).to have_text(target_l1.title)
      expect(page).to have_text("ASK A NEW QUESTION")

      # Try clearing the linking.
      click_link 'Clear'

      expect(page).not_to have_text(target_l1.title)
      expect(page).to have_text("ASK A NEW QUESTION")

      # Let's go back to linked state and try creating a linked question.
      visit(new_question_community_path(community_1, target_id: target_l1.id))

      fill_in 'Question', with: question_title
      replace_markdown(question_description)
      click_button 'Post Your Question'

      expect(page).to have_text(question_title)
      expect(page).to have_text(question_description)
      expect(page).not_to have_text("ASK A NEW QUESTION")

      # The question should have been linked to the target.
      expect(Question.where(title: question_title).first.targets.first).to eq(target_l1)

      # Return to the target overlay. Student should be able to their question there now.
      visit target_path(target_l1)
      find('.course-overlay__body-tab-item', text: 'Discuss').click

      expect(page).to have_text(community_1.name)
      expect(page).to have_text(question_title)

      # Student can filter all questions linked to the target.
      find("a[title='Browse all questions about this target in the #{community_1.name} community'").click
      expect(page).to have_text('Clear Filter')
      expect(page).to have_text(question_title)
      expect(page).not_to have_text(question_1.title)
      expect(page).not_to have_text(question_2.title)

      # Student see all questions in the community by clearing the filter.
      click_link 'Clear Filter'
      expect(page).to have_text(question_title)
      expect(page).to have_text(question_1.title)
      expect(page).to have_text(question_2.title)
    end
  end

  scenario "student visits a target's page directly" do
    # The level selected in the curriculum list underneath should always match the target.
    sign_in_user student.user, referer: target_path(target_l0)

    click_button('Close')

    expect(page).to have_text(target_group_l0.name)

    visit target_path(target_l2)

    click_button('Close')

    expect(page).to have_text(target_group_l2.name)
  end

  context 'when accessing preview mode of curriculum' do
    let(:school_admin) { create :school_admin }

    scenario "target show page should render in preview mode" do
      sign_in_user school_admin.user, referer: target_path(target_l1)
      expect(page).to have_content('You are currently looking at a preview of this course.')
    end

    scenario 'tries to submit work on a target' do
      sign_in_user school_admin.user, referer: target_path(target_l1)

      # This target should have a 'Complete' section.
      find('.course-overlay__body-tab-item', text: 'Complete').click

      # The submit button should be disabled.
      expect(page).to have_button('Submit', disabled: true)
      fill_in 'Work on your submission', with: Faker::Lorem.sentence

      expect(page).to have_button('Submit', disabled: true)

      find('a', text: 'Add URL').click
      fill_in 'attachment_url', with: 'foobar'
      expect(page).to have_content('does not look like a valid URL')
      fill_in 'attachment_url', with: 'https://example.com?q=1'
      click_button 'Attach link'

      # The submit button should be disabled.
      expect(page).to have_button('Submit', disabled: true)

      find('a', text: 'Upload File').click
      attach_file 'attachment_file', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'human.png')), visible: false
      find('a', text: 'Add URL').click
      fill_in 'attachment_url', with: 'https://example.com?q=2'
      click_button 'Attach link'
      dismiss_notification

      # The submit button should be disabled.
      expect(page).to have_button('Submit', disabled: true)
    end

    context 'when the target is auto-verified' do
      let!(:target_l1) { create :target, :with_content, target_group: target_group_l1, role: Target::ROLE_TEAM, completion_instructions: Faker::Lorem.sentence }

      scenario 'tries to completes an auto-verified target' do
        sign_in_user school_admin.user, referer: target_path(target_l1)

        # There should be a mark as complete button on the learn page.
        expect(page).to have_button('Mark As Complete', disabled: true)
      end
    end

    context 'when the target requires user to visit a link to complete it' do
      let(:link_to_complete) { "https://www.example.com/#{Faker::Lorem.word}" }
      let!(:target_with_link) { create :target, target_group: target_group_l1, link_to_complete: link_to_complete, completion_instructions: Faker::Lorem.sentence }

      scenario 'link to complete is shown to the user' do
        sign_in_user school_admin.user, referer: target_path(target_with_link)

        expect(page).to have_link('Visit Link', href: link_to_complete)
      end
    end

    context 'when the target requires user to take a quiz to complete it ' do
      scenario 'user can view all the questions' do
        sign_in_user school_admin.user, referer: target_path(quiz_target)

        within('.course-overlay__header-title-card') do
          expect(page).to have_content(quiz_target.title)
          expect(page).to have_content('Pending')
        end

        find('.course-overlay__body-tab-item', text: 'Take Quiz').click

        # Question one
        expect(page).to have_content(/Question #1/i)
        expect(page).to have_content(quiz_question_1.question)
        find('.quiz-root__answer', text: q1_answer_1.value).click
        click_button('Next Question')

        # Question two
        expect(page).to have_content(/Question #2/i)
        expect(page).to have_content(quiz_question_2.question)
        find('.quiz-root__answer', text: q2_answer_4.value).click
        expect(page).to have_button('Submit Quiz', disabled: true)
      end
    end
  end
end
