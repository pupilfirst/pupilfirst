require 'rails_helper'

feature 'Community', js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper

  # Setup a course with students and target for community.
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:level_1_c2) { create :level, :one, course: course_2 }
  let(:target_group) { create :target_group, level: level_1 }
  let!(:target) { create :target, target_group: target_group }
  let!(:community) { create :community, school: school, target_linkable: true }
  let(:team) { create :team, level: level_1 }
  let(:student_1) { create :student, startup: team }
  let(:student_2) { create :student, startup: team }
  let(:coach) { create :faculty, school: school }
  let(:school_admin) { create :school_admin }
  let!(:topic_1) { create :topic, :with_first_post, community: community, creator: student_1.user }
  let!(:topic_2) { create :topic, :with_first_post, community: community, creator: student_1.user }
  let!(:topic_3) { create :topic, :with_first_post, community: community, target: target, creator: student_1.user }
  let!(:reply_1) { create :post, topic: topic_1, creator: student_1.user, post_number: 2 }
  let(:topic_title) { Faker::Lorem.sentence }
  let(:topic_body) { Faker::Lorem.paragraph }
  let(:topic_body_for_edit) { Faker::Lorem.paragraph }
  let(:reply_body) { Faker::Lorem.paragraph }
  let(:reply_body_for_edit) { Faker::Lorem.paragraph }
  let(:reply_for_topic) { Faker::Lorem.sentence }
  let(:reply_for_another_post) { Faker::Lorem.sentence }

  let(:course_2) { create :course, school: school }
  let(:team_c2) { create :team, level: level_1_c2 }
  let(:student_c2) { create :student, startup: team_c2 }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course
    create :community_course_connection, course: course, community: community
    create :community_course_connection, course: course_2, community: community
  end

  scenario 'user who is not logged in tries to visit community' do
    visit community_path(community)
    expect(page).to have_text("Please sign in to continue.")
  end

  scenario 'an active student visits his community' do
    sign_in_user(student_1.user, referer: community_path(community))

    # All questions should be visible.
    expect(page).to have_text(community.name)
    expect(page).to have_text(topic_1.title)
    expect(page).to have_text(topic_2.title)
    expect(page).to have_text(topic_3.title)
  end

  scenario 'an active student creates a post in his community' do
    sign_in_user(student_1.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link 'Create a new topic'
    expect(page).to have_text("Create a new topic of discussion")
    fill_in 'Title', with: topic_title
    replace_markdown topic_body
    click_button 'Create Post'

    expect(page).not_to have_text("Create a new topic of discussion")
    expect(page).to have_text(topic_title)
    expect(page).to have_text(topic_body)
    expect(community.topics.reload.find_by(title: topic_title).first_post.body).to eq(topic_body)
  end

  scenario 'an active student participates in a topic thread' do
    sign_in_user(student_2.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link topic_1.title

    # Topic and replies are visible
    expect(page).to have_text(topic_1.first_post.body)
    expect(page).to have_text(reply_1.body)

    # Only a faculty or the creator can edit or delete a topic
    within("div#post-show-#{topic_1.first_post.id}") do
      expect(page).not_to have_text("Edit Title")
      expect(page).not_to have_selector("div[aria-label='Options for post #{topic_1.first_post.id}']")
    end

    # any one with access to the community can reply to a topic
    replace_markdown reply_body
    click_button 'Post Your Reply'
    dismiss_notification

    # A notification should have been mailed to the question author.
    open_email(topic_1.creator.email)
    expect(current_email.subject).to eq('New reply for your post')
    expect(current_email.body).to include("#{student_2.user.name} has posted a reply to something you said on the #{community.name} community")
    expect(current_email.body).to include("/topics/#{topic_1.id}")

    expect(page).to have_text("2 Replies")
    new_reply = topic_1.reload.replies.last
    expect(new_reply.body).to eq(reply_body)

    # can edit his reply
    find("div[aria-label='Options for post #{new_reply.id}']").click
    click_button 'Edit Reply'
    within("div#post-show-#{new_reply.id}") do
      replace_markdown reply_body_for_edit
    end
    click_button 'Update Reply'

    expect(page).not_to have_text(reply_body)
    expect(new_reply.reload.body).to eq(reply_body_for_edit)
    expect(new_reply.text_versions.first.value).to eq(reply_body)

    # can see post edit history
    find("div[aria-label='Options for post #{new_reply.id}']").click
    click_link 'History'
    expect(page).to have_text('Post Edit History')
    expect(page).to have_text(reply_body)
    expect(page).to have_text(reply_body_for_edit)
    click_link 'Back to Post'

    # can archive his reply
    find("div[aria-label='Options for post #{new_reply.id}']").click
    click_button 'Delete Reply'
    page.driver.browser.switch_to.alert.accept

    dismiss_notification

    expect(page).not_to have_text(reply_body_for_edit)
    expect(new_reply.reload.archived_at).to_not eq(nil)

    # can add reply to another post
    find("button[aria-label='Add reply to post #{reply_1.id}']").click
    replace_markdown 'This is a reply to another post'
    within("div[aria-label='Add new reply']") do
      expect(page).to have_text("Reply To")
      expect(page).to have_text(reply_1.creator.name)
    end
    click_button 'Post Your Reply'

    dismiss_notification

    # A mail should have been sent to post author.
    open_email(reply_1.creator.email)
    expect(current_email.subject).to eq('New reply for your post')
    expect(current_email.body).to include("New reply for your post")
    expect(current_email.body).to include("#{student_2.user.name} has posted a reply to something you said on the #{community.name} community")
    expect(current_email.body).to include("/topics/#{topic_1.id}")

    # check saved reply
    expect(topic_1.replies.reload.last.body).to eq('This is a reply to another post')
    expect(topic_1.replies.last.reply_to_post_id).to eq(reply_1.id)

    # Reply appears in the main list and as a thread to it's parent post
    find("button[aria-label='Show replies of post #{reply_1.id}']").click
    expect(page).to have_text('This is a reply to another post', count: 2)

    # can like and unlike a reply
    find("div[aria-label='Like reply #{reply_1.id}']").click
    expect(page).to have_selector("div[aria-label='Unlike reply #{reply_1.id}']")
    expect(reply_1.post_likes.where(user: student_2.user).count).to eq(1)

    find("div[aria-label='Unlike reply #{reply_1.id}']").click
    expect(page).to have_selector("div[aria-label='Like reply #{reply_1.id}']")
    expect(reply_1.post_likes.where(user: student_2.user).count).to eq(0)
  end

  scenario 'an active faculty visits community' do
    sign_in_user(coach.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link topic_1.title

    # Topic and replies are visible
    expect(page).to have_text(topic_1.first_post.body)
    expect(page).to have_text(reply_1.body)

    # Faculty can edit or delete a topic
    find("h3[aria-label='Topic Title']").hover
    expect(page).to have_text("Edit Title")
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    expect(page).to have_text("Edit Post")
    expect(page).to have_text("Delete Post")
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click

    # Faculty can edit or delete replies
    find("div[aria-label='Options for post #{reply_1.id}']").click
    expect(page).to have_text("Edit Reply")
    expect(page).to have_text("Delete Reply")
    find("div[aria-label='Options for post #{reply_1.id}']").click

    # Faculty edits a topic body
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    click_button 'Edit Post'

    old_description = topic_1.first_post.body
    within("div#post-show-#{topic_1.first_post.id}") do
      replace_markdown topic_body_for_edit
      click_button 'Update Post'
    end

    dismiss_notification

    expect(page).not_to have_text(old_description)
    expect(topic_1.first_post.reload.body).to eq(topic_body_for_edit)
    expect(topic_1.first_post.text_versions.first.value).to eq(old_description)

    # can see topic edit history
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    click_link 'History'
    expect(page).to have_text(old_description)
    expect(page).to have_text(topic_body_for_edit)
    click_link 'Back to Post'

    # can mark a reply as solution
    find("div[aria-label='Options for post #{reply_1.id}']").click
    click_button 'Mark as solution'
    within("div#post-show-#{reply_1.id}") do
      expect(page).to have_selector("div[aria-label='Marked as solution icon']")
    end

    expect(topic_1.replies.reload.where(solution: true).count).to eq(1)
    expect(topic_1.replies.where(solution: true).first).to eq(reply_1)
  end

  scenario 'topic creator can mark a post as solution' do
    sign_in_user(student_1.user, referer: topic_path(topic_1))

    find("div[aria-label='Options for post #{reply_1.id}']").click
    click_button 'Mark as solution'
    within("div#post-show-#{reply_1.id}") do
      expect(page).to have_selector("div[aria-label='Marked as solution icon']")
    end
  end

  scenario "topic creator can delete a topic when it doesn't have unarchived replies" do
    sign_in_user(student_1.user, referer: topic_path(topic_1))

    # When the topic has a reply, the first post won't have the delete option.
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    expect(page).not_to have_button('Delete Post')

    # So, let's delete the sole reply.
    find("div[aria-label='Options for post #{reply_1.id}']").click
    accept_confirm { click_button('Delete Reply') }

    expect(page).to have_text('Post archived successfully')
    dismiss_notification

    # This should make the delete option visible on the first post.
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    accept_confirm { click_button('Delete Post') }

    # Student should be back on the community main page.
    expect(page).to have_text(topic_2.title)

    expect(topic_1.reload.archived).to eq(true)
    expect(topic_1.first_post.archived_at).to be_present
    expect(topic_1.first_post.archiver).to eq(student_1.user)
  end

  scenario 'a target-linked question is viewed by student with access to target' do
    # The target should be mentioned and linked on the question page.
    sign_in_user(student_1.user, referer: topic_path(topic_3))

    expect(page).to have_text(target.title)
    expect(page).to have_link('View Target', href: target_path(target))
  end

  scenario 'a target-linked question is viewed by student without access to target' do
    # The target should be mentioned...
    sign_in_user(student_c2.user, referer: topic_path(topic_3))

    expect(page).to have_text(target.title)

    # ...but not linked.
    expect(page).not_to have_link('View Target')
  end

  scenario 'school admin visits community' do
    sign_in_user(school_admin.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link topic_1.title

    # Question and answers are visible
    expect(page).to have_text(topic_1.first_post.body)
    expect(page).to have_text(reply_1.body)
  end
end
