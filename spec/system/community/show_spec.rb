require 'rails_helper'

feature 'Community Show' do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with founders and target for community.
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1 }
  let!(:target) { create :target, target_group: target_group }
  let!(:community) { create :community, school: school, target_linkable: true }
  let(:startup) { create :startup, level: level_1 }
  let(:founder_1) { create :founder, startup: startup }
  let(:founder_2) { create :founder, startup: startup }
  let(:coach) { create :faculty, school: school }
  let!(:question_1) { create :question, community: community, creator: founder_1.user }
  let!(:question_2) { create :question, community: community, creator: founder_1.user }
  let!(:question_3) { create :question, community: community, creator: founder_1.user }
  let!(:answer_1) { create :answer, question: question_1, creator: founder_1.user }
  let(:question_title) { Faker::Lorem.sentence }
  let(:question_description) { Faker::Lorem.paragraph }
  let(:question_description_for_edit) { Faker::Lorem.paragraph }
  let(:answer_description) { Faker::Lorem.paragraph }
  let(:answer_description_for_edit) { Faker::Lorem.paragraph }
  let(:comment_for_question) { Faker::Lorem.sentence }
  let(:comment_for_answer) { Faker::Lorem.sentence }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course
    create :community_course_connection, course: course, community: community
  end

  scenario 'when an unknown user visits a community' do
    visit community_path(community)

    # Should 404.
    expect(page).to have_content("The page you were looking for doesn't exist")
  end

  scenario 'When an active founder visits his community', js: true do
    sign_in_user(founder_1.user, referer: community_path(community))

    # All questions should be visible.
    expect(page).to have_text(community.name)
    expect(page).to have_text(question_1.title)
    expect(page).to have_text(question_2.title)
    expect(page).to have_text(question_3.title)
  end

  scenario 'When an active founder creates a question in his community', js: true do
    sign_in_user(founder_1.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link 'Ask a question'
    expect(page).to have_text("ASK A NEW QUESTION")
    fill_in 'Title', with: question_title
    fill_in 'Body', with: question_description
    click_button 'Post Your Question'

    expect(page).to have_text(question_title)
    expect(page).to have_text(question_description)
    expect(page).not_to have_text("ASK A NEW QUESTION")
  end

  scenario 'When an active founder clicks on a question', js: true do
    sign_in_user(founder_2.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link question_1.title

    # Question and answers are visible
    expect(page).to have_text(question_1.description)
    expect(page).to have_text(answer_1.description)

    # Only a faculty or the creator can edit or delete a question
    expect(page).not_to have_text("Edit")
    expect(page).not_to have_text("Delete")

    # any one with access to the community can answer a question
    fill_in 'Your Answer', with: answer_description
    click_button 'Post Your Answer'

    dismiss_notification

    expect(page).to have_text("2 Answers")
    new_answer = question_1.reload.answers.last
    expect(new_answer.description).to eq(answer_description)

    # can edit his answer
    find('a[title="Edit Answer"]').click
    fill_in 'Your Answer', with: answer_description_for_edit
    click_button 'Update Your Answer'

    dismiss_notification

    expect(page).not_to have_text(answer_description)
    expect(new_answer.reload.description).to eq(answer_description_for_edit)
    expect(new_answer.text_versions.first.value).to eq(answer_description)

    # can see answer edit history
    click_link 'History'
    expect(page).to have_text('Answer Edit History')
    expect(page).to have_text(answer_description)
    expect(page).to have_text(answer_description_for_edit)
    click_link 'Back to Answer'

    # can archive his answer
    find('a[title="Archive Answer"]').click
    page.driver.browser.switch_to.alert.accept

    dismiss_notification

    expect(page).not_to have_text(answer_description_for_edit)
    expect(new_answer.reload.archived).to eq(true)

    # can add a comment for question
    comment_field = find('input[title="Add your comment for Question"]')
    comment_field.fill_in with: comment_for_question
    click_button 'Comment'

    dismiss_notification

    comment_1 = Comment.where(commentable_id: question_1.id, commentable_type: "Question").last
    expect(comment_1.value).to eq(comment_for_question)

    # can archive his comment for question
    find('a[title="Archive Comment"]').click
    page.driver.browser.switch_to.alert.accept

    dismiss_notification

    expect(page).not_to have_text(comment_for_question)
    expect(comment_1.reload.archived).to eq(true)

    # can add a comment for answer
    comment_field = find('input[title="Add your comment for Answer"]')
    comment_field.fill_in with: comment_for_answer
    click_button 'Comment'

    dismiss_notification

    comment_2 = Comment.where(commentable_id: answer_1.id, commentable_type: "Answer").last
    expect(comment_2.value).to eq(comment_for_answer)

    # can archive his comment for question
    find('a[title="Archive Comment"]').click
    page.driver.browser.switch_to.alert.accept

    dismiss_notification

    expect(page).not_to have_text(comment_for_answer)
    expect(comment_2.reload.archived).to eq(true)

    # can like and unlike an answer
    within("div[title=\"Answer #{answer_1.id}\"]") do
      find('div[title="Like Answer"]').click
      expect(page).to have_selector('div[title="Unlike Answer"]')
      expect(AnswerLike.where(answer: answer_1, user: founder_2.user).count).to eq(1)

      find('div[title="Unlike Answer"]').click
      expect(page).to have_selector('div[title="Like Answer"]')
      expect(AnswerLike.where(answer: answer_1, user: founder_2.user).count).to eq(0)
    end
  end

  scenario 'When an active faculty visits community', js: true do
    sign_in_user(coach.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link question_1.title

    # Question and answers are visible
    expect(page).to have_text(question_1.description)
    expect(page).to have_text(answer_1.description)

    # Faculty can edit or delete a question
    within('div[title="Question block"]') do
      expect(page).to have_text("Edit")
      expect(page).to have_text("Delete")
    end

    # Faculty can edit or delete answer
    within("div[title=\"Answer #{answer_1.id}\"]") do
      expect(page).to have_text("Edit")
      expect(page).to have_text("Delete")
    end

    # Faculty edits a question description
    within('div[title="Question block"]') do
      find('a[title="Edit Question"]').click
    end

    old_description = question_1.description
    fill_in 'Body', with: question_description_for_edit
    click_button 'Update Question'

    dismiss_notification

    expect(page).not_to have_text(old_description)
    expect(question_1.reload.description).to eq(question_description_for_edit)
    expect(question_1.text_versions.first.value).to eq(old_description)

    # can see question edit history
    click_link 'History'
    expect(page).to have_text('Question Edit History')
    expect(page).to have_text(question_1.title)
    expect(page).to have_text(old_description)
    expect(page).to have_text(question_description_for_edit)
    click_link 'Back to Question'
  end
end
