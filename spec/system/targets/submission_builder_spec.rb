require 'rails_helper'

feature 'Submission Builder', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  let(:course) { create :course }
  let(:grade_labels_for_1) { [{ 'grade' => 1, 'label' => 'Bad' }, { 'grade' => 2, 'label' => 'Good' }, { 'grade' => 3, 'label' => 'Great' }, { 'grade' => 4, 'label' => 'Wow' }] }
  let!(:criterion_1) { create :evaluation_criterion, course: course, max_grade: 4, pass_grade: 2, grade_labels: grade_labels_for_1 }
  let!(:level_1) { create :level, :one, course: course }
  let!(:team) { create :startup, level: level_1 }
  let!(:student) { team.founders.first }
  let!(:target_group_l1) { create :target_group, level: level_1, milestone: true }
  let!(:target) { create :target, :with_content, target_group: target_group_l1, role: Target::ROLE_TEAM, evaluation_criteria: [criterion_1] }

  scenario 'student visits a target with no checklist' do
    sign_in_user student.user, referer: target_path(target)

    # This target should have a 'Complete' section.
    find('.course-overlay__body-tab-item', text: 'Complete').click

    expect(page).to have_text("This target has no actions. Click submit to complete the target")

    find('button', text: 'Submit').click

    expect(page).to have_content('Your submission has been queued for review')

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq([])

    # The submission contents should be on the page.
    expect(page).to have_content("Target was marked as complete.")
  end

  scenario 'student visits a target with no checklist' do
    question = Faker::Lorem.sentence
    target.update!(checklist: [{ title: question, kind: Target::CHECKLIST_KIND_LONG_TEXT, optional: false }])
    long_answer = 'Sum deskripshun. Oops. Typoos aplenty.'

    sign_in_user student.user, referer: target_path(target)

    # This target should have a 'Complete' section.
    find('.course-overlay__body-tab-item', text: 'Complete').click

    within("div[aria-label='0-longText'") do
      expect(page).to have_content(question)
    end

    # The submit button should be disabled at this point.
    expect(page).to have_button('Submit', disabled: true)

    # Filling in with a bunch of spaces should not work.
    fill_in question, with: '   '

    expect(page).to have_button('Submit', disabled: true)

    # The user should be able to write text as description
    fill_in question, with: long_answer

    find('button', text: 'Submit').click

    expect(page).to have_content('Your submission has been queued for review')

    last_submission = TimelineEvent.last
    expect(last_submission.checklist).to eq([{ "kind" => "longText", "title" => question, "result" => long_answer, "status" => "noAnswer" }])

    expect(page).to have_text('Your Submissions')
    expect(page).to have_text(question)
    expect(page).to have_text(long_answer)
  end
end

# # User should be able to undo the submission.
# accept_confirm do
#   click_button('Undo sumission')
# end
#
# # This action should reload the page and return the user to the content of the target.
# expect(page).to have_selector('.learn-content-block__embed')
#
# # The last submissions should have been deleted...
# expect { last_submission.reload }.to raise_exception(ActiveRecord::RecordNotFound)
#
# # ...and the complete section should be accessible again.
# expect(page).to have_selector('.course-overlay__body-tab-item', text: 'Complete')

# # Filling in with a bunch of spaces should not work.
# fill_in 'Work on your submission', with: '   '
# expect(page).to have_button('Submit', disabled: true)
#
# # The user should be able to write text as description and attach upto three links and / or files.
# fill_in 'Work on your submission', with: bad_description
#
# # The submit button should be enabled now.
# expect(page).to have_button('Submit')
#
# find('a', text: 'Add URL').click
# fill_in 'attachment_url', with: 'foobar'
# expect(page).to have_content('does not look like a valid URL')
# fill_in 'attachment_url', with: 'https://example.com?q=1'
#
# # The submit button should be disabled when the link is being typed in.
# expect(page).not_to have_button('Submit')
# expect(page).to have_button('Finish adding link...', disabled: true)
#
# click_button 'Attach link'
#
# # The submit button should be enabled again now.
# expect(page).to have_button('Submit')
#
# find('a', text: 'Upload File').click
# attach_file 'attachment_file', File.absolute_path(Rails.root.join('spec/support/uploads/faculty/human.png')), visible: false
# find('a', text: 'Add URL').click
# fill_in 'attachment_url', with: 'https://example.com?q=2'
# click_button 'Attach link'
#
# expect(page).to have_link('human.png', href: "/timeline_event_files/#{TimelineEventFile.last.id}/download")
# expect(page).to have_link(link_1, href: link_1)
# expect(page).to have_link(link_2, href: link_2)
#
# # The attachment forms should have disappeared now.
# expect(page).not_to have_selector('a', text: 'Add URL')
# expect(page).not_to have_selector('a', text: 'Upload File')

# find('button', text: 'Submit').click
#
# expect(page).to have_content('Your submission has been queued for review')

# # The state of the target should change.
# within('.course-overlay__header-title-card') do
#   expect(page).to have_content('Submitted')
# end
#
# # The submissions should mention that review is pending.
# expect(page).to have_content('Review pending')
#
# # The student should be able to undo the submission at this point.
# expect(page).to have_button('Undo sumission')
#
# # User should be looking at their submission now.
# expect(page).to have_content('Your Submissions')

# Let's check the database to make sure the submission was created correctly
# last_submission = TimelineEvent.last
# expect(last_submission.description).to eq(bad_description)
# expect(last_submission.links).to contain_exactly(link_1, link_2)
# expect(last_submission.timeline_event_files.first.file.filename).to eq('human.png')
#
# # The status should also be updated on the home page.
# click_button 'Close'
#
# within("a[aria-label='Select Target #{target_l1.id}'") do
#   expect(page).to have_content('Submitted')
# end
#
# # Return to the submissions & feedback tab on the target overlay.
# click_link target_l1.title
# find('.course-overlay__body-tab-item', text: 'Submissions & Feedback').click
#
# # The submission contents should be on the page.
# expect(page).to have_content(bad_description)
# expect(page).to have_link('human.png', href: "/timeline_event_files/#{TimelineEventFile.last.id}/download")
# expect(page).to have_link(link_1, href: link_1)
# expect(page).to have_link(link_2, href: link_2)
#
# # User should be able to undo the submission.
# accept_confirm do
#   click_button('Undo sumission')
# end
#
# # This action should reload the page and return the user to the content of the target.
# expect(page).to have_selector('.learn-content-block__embed')
#
# # The last submissions should have been deleted...
# expect { last_submission.reload }.to raise_exception(ActiveRecord::RecordNotFound)
#
# # ...and the complete section should be accessible again.
# expect(page).to have_selector('.course-overlay__body-tab-item', text: 'Complete')
