require 'rails_helper'

feature 'Community', js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper
  include ActiveSupport::Testing::TimeHelpers

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
  let!(:topic_1) { create :topic, :with_first_post, community: community, creator: student_1.user, last_activity_at: 1.second.ago }
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
    create :topic_subscription, topic: topic_1, user: coach.user
  end

  scenario 'user who is not logged in tries to visit community' do
    visit community_path(community)
    expect(page).to have_text('Please sign in to continue.')
  end

  scenario 'student from an unlinked course attempts to visit community' do
    CommunityCourseConnection.where(course: course).destroy_all

    sign_in_user(student_1.user, referrer: community_path(community))

    expect(page).to have_text("The page you were looking for doesn't exist")
  end

  scenario 'an active student visits his community' do
    sign_in_user(student_1.user, referrer: community_path(community))

    # All questions should be visible.
    expect(page).to have_text(community.name)
    expect(page).to have_text(topic_1.title)
    expect(page).to have_text(topic_2.title)
    expect(page).to have_text(topic_3.title)
  end

  scenario 'an active student creates a post in his community' do
    sign_in_user(student_1.user, referrer: community_path(community))
    expect(page).to have_text(community.name)

    click_link 'New Topic'
    expect(page).to have_text('Create a new topic of discussion')
    fill_in 'Title', with: topic_title
    replace_markdown topic_body
    click_button 'Create Topic'

    expect(page).not_to have_text('Create a new topic of discussion')
    expect(page).to have_text(topic_title)
    expect(page).to have_text(topic_body)
    expect(community.topics.reload.find_by(title: topic_title).first_post.body).to eq(topic_body)
  end

  scenario 'a student edits her post and leaves a reason' do
    sign_in_user(student_1.user, referrer: topic_path(topic_1))

    first_reason = Faker::Lorem.unique.sentence
    second_reason = Faker::Lorem.unique.sentence

    # Edit a reply and set reason first time.
    find("div[aria-label='Options for post #{reply_1.id}']").click
    click_button 'Edit Reply'

    within("div#post-show-#{reply_1.id}") do
      replace_markdown reply_body_for_edit
    end

    fill_in 'edit-reason', with: first_reason
    click_button 'Update Reply'

    # Edit a reply and set reason second time.
    find("div[aria-label='Options for post #{reply_1.id}']").click
    click_button 'Edit Reply'

    within("div#post-show-#{reply_1.id}") do
      replace_markdown reply_body_for_edit
    end

    fill_in 'edit-reason', with: second_reason
    click_button 'Update Reply'

    # Go to the history page history - the reason should be there.
    find("div[aria-label='Options for post #{reply_1.id}']").click
    click_link 'History'

    expect(page).to have_text(first_reason)
    expect(page).to have_text(second_reason)
  end

  scenario 'an active student participates in a topic thread' do
    sign_in_user(student_2.user, referrer: community_path(community))
    expect(page).to have_text(community.name)

    click_link topic_1.title

    # Topic and replies are visible
    expect(page).to have_text(topic_1.first_post.body)
    expect(page).to have_text(reply_1.body)

    # Only a faculty or the creator can edit or delete a topic
    within("div#post-show-#{topic_1.first_post.id}") do
      expect(page).not_to have_text('Edit Title')
      expect(page).not_to have_selector("div[aria-label='Options for post #{topic_1.first_post.id}']")
    end

    # any one with access to the community can reply to a topic
    replace_markdown reply_body
    click_button 'Post Your Reply'

    expect(page).to have_text('Reply added successfully')
    dismiss_notification

    # A notification should have been mailed to the question author.
    open_email(topic_1.creator.email)
    expect(current_email.subject).to eq('New reply for your post')
    expect(current_email.body).to include("#{student_2.user.name} has posted a reply to something you said on the #{community.name} community")
    expect(current_email.body).to include("/topics/#{topic_1.id}")

    expect(page).to have_text('2 Replies')
    new_reply = topic_1.replies.find_by(post_number: 3)
    expect(new_reply.body).to eq(reply_body)

    expect(Notification.last.notifiable).to eq(new_reply)

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
    # Notifications created for the post must be deleted
    expect(Notification.count).to eq(0)

    # can add reply to another post
    find("button[aria-label='Add reply to post #{reply_1.id}']").click
    replace_markdown 'This is a reply to another post'
    within("div[aria-label='Add new reply']") do
      expect(page).to have_text('Reply To')
      expect(page).to have_text(reply_1.creator.name)
    end
    click_button 'Post Your Reply'

    dismiss_notification

    # A mail should have been sent to post author.
    open_email(reply_1.creator.email)
    expect(current_email.subject).to eq('New reply for your post')
    expect(current_email.body).to include('New reply for your post')
    expect(current_email.body).to include("#{student_2.user.name} has posted a reply to something you said on the #{community.name} community")
    expect(current_email.body).to include("/topics/#{topic_1.id}")

    # check saved reply
    last_reply = topic_1.replies.find_by(post_number: 4)
    expect(last_reply.body).to eq('This is a reply to another post')
    expect(last_reply.reply_to_post_id).to eq(reply_1.id)

    # Reply appears in the main list and as a thread to it's parent post
    find("button[aria-label='Show replies of post #{reply_1.id}']").click
    expect(page).to have_text('This is a reply to another post', count: 2)

    # can like and unlike a reply
    find("button[aria-label='Like post #{reply_1.id}']").click
    expect(page).to have_selector("button[aria-label='Unlike post #{reply_1.id}']")
    expect(reply_1.post_likes.where(user: student_2.user).count).to eq(1)

    find("button[aria-label='Unlike post #{reply_1.id}']").click
    expect(page).to have_selector("button[aria-label='Like post #{reply_1.id}']")
    expect(reply_1.post_likes.where(user: student_2.user).count).to eq(0)
  end

  scenario 'a user visiting a topic affects its view count' do
    original_views = topic_1.views

    sign_in_user(student_2.user, referrer: topic_path(topic_1))

    expect(page).to have_text(topic_1.first_post.body)

    # Views should have been incremented by 1.
    expect(topic_1.reload.views).to eq(original_views + 1)

    # Revisiting the page "soon" should not increase the count.
    click_link community.name
    expect(page).to have_link('New Topic')
    click_link topic_1.title

    expect(page).to have_text(topic_1.first_post.body)
    expect(topic_1.reload.views).to eq(original_views + 1)

    # Revisiting after a "long while" should increase the count again.
    travel_to(90.minutes.from_now) do
      click_link community.name
      expect(page).to have_link('New Topic')
      click_link topic_1.title

      expect(page).to have_text(topic_1.first_post.body)
      expect(topic_1.reload.views).to eq(original_views + 2)
    end
  end

  scenario 'an active faculty visits community' do
    sign_in_user(coach.user, referrer: community_path(community))
    expect(page).to have_text(community.name)

    click_link topic_1.title

    # Topic and replies are visible
    expect(page).to have_text(topic_1.first_post.body)
    expect(page).to have_text(reply_1.body)

    # Faculty can edit or delete a topic
    find("h3[aria-label='Topic Title']").hover
    expect(page).to have_text('Edit Topic')
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    expect(page).to have_text('Edit Post')
    expect(page).to have_text('Delete Topic')
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click

    # Faculty can edit or delete replies
    find("div[aria-label='Options for post #{reply_1.id}']").click
    expect(page).to have_text('Edit Reply')
    expect(page).to have_text('Delete Reply')
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
    within("div#post-show-#{reply_1.id}") do
      accept_confirm { find("button[aria-label='Mark as solution']").click }
      expect(page).to have_selector("div[aria-label='Marked as solution icon']")
    end

    expect(topic_1.replies.reload.where(solution: true).count).to eq(1)
    expect(topic_1.replies.where(solution: true).first).to eq(reply_1)
  end

  scenario 'topic creator can mark a post as solution' do
    sign_in_user(student_1.user, referrer: topic_path(topic_1))

    within("div#post-show-#{reply_1.id}") do
      accept_confirm { find("button[aria-label='Mark as solution']").click }
      expect(page).to have_selector("div[aria-label='Marked as solution icon']")
    end
  end

  scenario "topic creator can delete a topic when it doesn't have unarchived replies" do
    sign_in_user(student_1.user, referrer: topic_path(topic_1))

    # When the topic has a reply, the first post won't have the delete option.
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    expect(page).not_to have_button('Delete Topic')

    # So, let's delete the sole reply.
    find("div[aria-label='Options for post #{reply_1.id}']").click
    accept_confirm { click_button('Delete Reply') }

    expect(page).to have_text('Post archived successfully')
    dismiss_notification

    # This should make the delete option visible on the first post.
    find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
    accept_confirm { click_button('Delete Topic') }

    # Student should be back on the community main page.
    expect(page).to have_text(topic_2.title)

    expect(topic_1.reload.archived).to eq(true)
    expect(topic_1.first_post.archived_at).to be_present
    expect(topic_1.first_post.archiver).to eq(student_1.user)
  end

  scenario 'a target-linked question is viewed by student with access to target' do
    # The target should be mentioned and linked on the question page.
    sign_in_user(student_1.user, referrer: topic_path(topic_3))

    expect(page).to have_text(target.title)
    expect(page).to have_link('View Target', href: target_path(target))
  end

  scenario 'a target-linked question is viewed by student without access to target' do
    # The target should be mentioned...
    sign_in_user(student_c2.user, referrer: topic_path(topic_3))

    expect(page).to have_text(target.title)

    # ...but not linked.
    expect(page).not_to have_link('View Target')
  end

  scenario 'coach marks a post as solution, edits content, and checks last edited info' do
    sign_in_user(coach.user, referrer: topic_path(topic_1))

    find("div[aria-label='Options for post #{reply_1.id}']").click

    within("div#post-show-#{reply_1.id}") do
      accept_confirm { find("button[aria-label='Mark as solution']").click }
      expect(page).to have_selector("div[aria-label='Marked as solution icon']")
    end

    # Refresh page and check that marking solution doesn't update last edited info
    visit current_path

    within("div#post-show-#{reply_1.id}") do
      expect(page).to_not have_text('Last edited by')
    end

    # Edits the content of the post
    find("div[aria-label='Options for post #{reply_1.id}']").click
    click_button 'Edit Reply'

    within("div#post-show-#{reply_1.id}") do
      replace_markdown topic_body_for_edit
      click_button 'Update Reply'
    end

    # Check for correct last edited message
    within("div#post-show-#{reply_1.id}") do
      expect(page).to have_text("Last edited by #{coach.name}")
    end
  end

  scenario 'user searches for topics in community' do
    # Let's set the titles for both topics to completely different sentences to avoid confusing the fuzzy search algo.
    topic_1.update!(title: 'Complex sentence with certain words')
    topic_2.update!(title: 'Completely Different Sequence')
    create :post, topic: topic_3, creator: student_1.user, post_number: 2, body: 'Another Complex Sentence'

    sign_in_user(coach.user, referrer: community_path(community))

    expect(page).to have_text(topic_2.title)

    fill_in 'filter', with: 'complex sentence'

    click_button "Search: complex sentence"

    expect(page).to_not have_text(topic_2.title)
    expect(page).to have_text(topic_1.title)
    expect(page).to have_text(topic_3.title)
  end

  scenario 'user plays around with subscription' do
    sign_in_user(student_1.user, referrer: topic_path(topic_1))

    expect(page).to have_text(topic_1.title)

    # can subscribe to a topic
    click_button 'Subscribe'
    expect(page).to have_text('Unsubscribe')
    expect(topic_1.subscribers).to include(student_1.user)

    # can Unsubscribe
    click_button 'Unsubscribe'
    expect(page).to have_text('Subscribe')
    expect(topic_1.subscribers).not_to include(student_1.user)
  end

  context 'when a topic has a archived replies and likes on its posts' do
    let(:archived_reply) { create :post, topic: topic_1, creator: student_1.user, post_number: 3, archiver: student_1.user, archived_at: Time.zone.now }

    before do
      # A like on an archived post or a reply should not be counted.
      create :post_like, post: archived_reply
      create :post_like, post: reply_1

      # Likes on the first post and replies should be counted.
      create_list :post_like, 3, post: topic_1.first_post
    end

    scenario 'user views likes and replies on the index page' do
      sign_in_user(student_2.user, referrer: community_path(community))

      within(find("a[aria-label='Topic #{topic_1.id}']")) do
        within(find('span[aria-label="Likes"]')) do
          expect(page).to have_text(3)
        end

        within(find('span[aria-label="Replies"]')) do
          expect(page).to have_text(1)
        end
      end
    end
  end

  context 'when a user is a school admin' do
    let(:school_admin) { create :school_admin }

    scenario 'school admin interacts with the community' do
      sign_in_user(school_admin.user, referrer: community_path(community))
      expect(page).to have_text(community.name)

      click_link topic_1.title

      # Question and answers are visible
      expect(page).to have_text(topic_1.first_post.body)
      expect(page).to have_text(reply_1.body)

      # Like a post.
      find("button[aria-label='Like post #{topic_1.first_post.id}']").click
      expect(page).to have_selector("button[aria-label='Unlike post #{topic_1.first_post.id}']")

      # Edit a post.
      find("div[aria-label='Options for post #{topic_1.first_post.id}']").click
      click_button 'Edit Post'
      old_description = topic_1.first_post.body

      within("div#post-show-#{topic_1.first_post.id}") do
        replace_markdown topic_body_for_edit
        click_button 'Update Post'
      end

      dismiss_notification

      expect(page).not_to have_text(old_description)

      # Archive a post.
      find("div[aria-label='Options for post #{reply_1.id}']").click
      accept_confirm { click_button('Delete Reply') }

      expect(page).to have_text('Post archived successfully')

      dismiss_notification

      # Post a reply.
      replace_markdown reply_body
      expect { click_button 'Post Your Reply' }.to change { Post.count }.by(1)
      dismiss_notification

      # Create a new topic.
      click_link community.name
      click_link 'New Topic'
      fill_in 'Title', with: topic_title
      replace_markdown topic_body
      click_button 'Create Topic'

      expect(page).to have_text('0 Replies')
      expect(community.topics.reload.find_by(title: topic_title).first_post.body).to eq(topic_body)
    end

    scenario 'admin locks/unlocks a topic in community' do
      sign_in_user(school_admin.user, referrer: topic_path(topic_1))

      expect(page).to have_text(topic_1.title)
      expect(page).to_not have_text('This topic thread has been locked')

      accept_confirm { click_button('Lock Topic') }

      expect(page).to have_text('This topic has been locked')
      dismiss_notification

      expect(page).to have_text('This topic thread has been locked')

      expect(topic_1.reload.locked_at).to_not eq(nil)
      expect(topic_1.locked_by).to eq(school_admin.user)

      accept_confirm { click_button('Unlock Topic') }

      expect(page).to have_text('This topic has been unlocked')
      dismiss_notification

      expect(page).to_not have_text('This topic thread has been locked')

      expect(topic_1.reload.locked_at).to eq(nil)
      expect(topic_1.locked_by).to eq(nil)
    end
  end

  scenario 'student attempts to lock a topic' do
    sign_in_user(student_1.user, referrer: topic_path(topic_1))

    expect(page).to have_text(topic_1.title)
    expect(page).to_not have_button('Lock Topic')
  end

  scenario 'coach attempts to lock/unlock a topic' do
    sign_in_user(coach.user, referrer: topic_path(topic_1))

    accept_confirm { click_button('Lock Topic') }

    expect(page).to have_text('This topic has been locked')
    dismiss_notification

    accept_confirm { click_button('Unlock Topic') }

    expect(page).to have_text('This topic has been unlocked')
    dismiss_notification
  end

  scenario 'student attempts to post reply to a locked topic' do
    sign_in_user(student_1.user, referrer: topic_path(topic_1))

    replace_markdown reply_body

    # Before posting reply, let's lock the topic.
    topic_1.update!(locked_at: Time.zone.now, locked_by: coach.user)

    click_button 'Post Your Reply'

    expect(page).to have_text('Cannot add reply to a locked topic')
  end

  context 'community has topic categories' do
    let!(:category_1) { create :topic_category, community: community }
    let!(:category_2) { create :topic_category, community: community }

    before do
      topic_1.update!(topic_category: category_1)
      topic_2.update!(topic_category: category_2)
    end

    scenario 'user checks category of topic in community index' do
      sign_in_user(student_1.user, referrer: community_path(community))

      within("a[aria-label='Topic #{topic_1.id}']") do
        expect(page).to have_text(category_1.name)
      end

      within("a[aria-label='Topic #{topic_2.id}']") do
        expect(page).to have_text(category_2.name)
      end
    end

    scenario 'user filters topics by category' do
      sign_in_user(student_1.user, referrer: community_path(community))

      fill_in 'filter', with: 'category'

      click_button "Category: #{category_1.name}"

      expect(page).to_not have_text(topic_2.title)
      expect(page).to have_text(topic_1.title)

      # Clear the filter
      find("button[title='Remove selection: #{category_1.name}']").click

      # Use the dropdown shortcut to filter topics
      find("div[aria-label='Selected category filter']").click

      find("div[aria-label='Select category #{category_2.name}']").click

      expect(page).to_not have_text(topic_1.title)
      expect(page).to have_text(topic_2.title)
    end

    scenario 'moderator updates category of a topic' do
      sign_in_user(coach.user, referrer: topic_path(topic_1))

      # Change category
      find("h3[aria-label='Topic Title']").hover
      click_button 'Edit Topic'

      find("div[aria-label='Selected category']").click
      find("div[aria-label='Select category #{category_2.name}']").click

      click_button 'Update Topic'

      dismiss_notification

      within("div[aria-label='Topic Details']") do
        expect(page).to have_text(category_2.name)
      end

      expect(topic_1.reload.topic_category).to eq(category_2)

      # Assign no category

      find("h3[aria-label='Topic Title']").hover
      click_button 'Edit Topic'

      find("div[aria-label='Selected category']").click
      find("div[aria-label='Select no category']").click

      click_button 'Update Topic'

      dismiss_notification

      expect(topic_1.reload.topic_category).to eq(nil)
    end
  end

  context 'community has a mix of solved and unsolved topics' do
    let!(:reply_marked_as_solution) { create :post, topic: topic_1, creator: student_1.user, post_number: 3, solution: true }
    let!(:reply_2) { create :post, topic: topic_2, creator: student_1.user, post_number: 2 }

    scenario 'user checks solved status in topics list' do
      sign_in_user(coach.user, referrer: community_path(community))

      within("a[aria-label='Topic #{topic_1.id}']") do
        expect(page).to have_selector("span[aria-label='Solved status icon']")
      end

      within("a[aria-label='Topic #{topic_2.id}']") do
        expect(page).to_not have_selector("span[aria-label='Solved status icon']")
      end
    end

    scenario 'user filters topics with or without solution' do
      sign_in_user(coach.user, referrer: community_path(community))

      fill_in 'filter', with: 'solution'

      click_button 'Solution: Solved'

      expect(page).to_not have_text(topic_2.title)
      expect(page).to have_text(topic_1.title)

      # Clear the filter
      find("button[title='Remove selection: Solved']").click

      expect(page).to have_text(topic_2.title)
      expect(page).to have_text(topic_1.title)

      fill_in 'filter', with: 'solution'

      click_button 'Solution: Unsolved'

      expect(page).to_not have_text(topic_1.title)
      expect(page).to have_text(topic_2.title)
    end

    scenario 'user visits show page of topic with solution and checks for solution navigation button' do
      sign_in_user(coach.user, referrer: topic_path(topic_1))

      within("div#post-show-#{topic_1.first_post.id}") do
        expect(page).to have_link('Go to solution', href: "#post-show-#{reply_marked_as_solution.id}")
      end
    end

    scenario 'user visits show page of topic without solution and checks for solution navigation button' do
      sign_in_user(coach.user, referrer: topic_path(topic_2))

      within("div#post-show-#{topic_2.first_post.id}") do
        expect(page).to_not have_link('Go to solution')
      end
    end
  end

  context 'topics have different views, creation date and last activity time' do
    let!(:topic_1) { create :topic, :with_first_post, community: community, creator: student_1.user, last_activity_at: 1.second.ago, created_at: 2.days.ago, views: 9 }
    let!(:topic_2) { create :topic, :with_first_post, community: community, creator: student_1.user, last_activity_at: 3.days.ago, created_at: 4.days.ago, views: 1 }
    let!(:topic_3) { create :topic, :with_first_post, community: community, creator: student_1.user, last_activity_at: 2.days.ago, created_at: 1.day.ago, views: 20 }

    scenario 'user sorts topics based on views, creation date and last activity' do
      sign_in_user(coach.user, referrer: community_path(community))

      within("div[aria-label='Change topics sorting']") do
        expect(page).to have_content("Posted At")
      end

      # Check current ordering of topics
      expect(find("#topics a:nth-child(1)")).to have_content(topic_3.title)
      expect(find("#topics a:nth-child(2)")).to have_content(topic_1.title)
      expect(find("#topics a:nth-child(3)")).to have_content(topic_2.title)

      #  Swap the ordering of topics
      click_button('toggle-sort-order')

      expect(find("#topics a:nth-child(3)")).to have_content(topic_3.title)
      expect(find("#topics a:nth-child(2)")).to have_content(topic_1.title)
      expect(find("#topics a:nth-child(1)")).to have_content(topic_2.title)

      # Change sorting criterion to last activity
      click_button 'Posted At'
      click_button 'Last Activity'

      expect(find("#topics a:nth-child(3)")).to have_content(topic_1.title)
      expect(find("#topics a:nth-child(2)")).to have_content(topic_3.title)
      expect(find("#topics a:nth-child(1)")).to have_content(topic_2.title)

      #  Swap the ordering of topics
      click_button('toggle-sort-order')

      expect(find("#topics a:nth-child(1)")).to have_content(topic_1.title)
      expect(find("#topics a:nth-child(2)")).to have_content(topic_3.title)
      expect(find("#topics a:nth-child(3)")).to have_content(topic_2.title)

      # Change sorting criterion to views
      click_button 'Last Activity'
      click_button 'Views'

      expect(find("#topics a:nth-child(1)")).to have_content(topic_3.title)
      expect(find("#topics a:nth-child(2)")).to have_content(topic_1.title)
      expect(find("#topics a:nth-child(3)")).to have_content(topic_2.title)

      click_button('toggle-sort-order')

      expect(find("#topics a:nth-child(3)")).to have_content(topic_3.title)
      expect(find("#topics a:nth-child(2)")).to have_content(topic_1.title)
      expect(find("#topics a:nth-child(1)")).to have_content(topic_2.title)
    end

    scenario 'user visits a community with filters applied' do
      sign_in_user(coach.user, referrer: community_path(community, sortDirection: 'Ascending', sortCriterion: 'Views', solution: 'Unsolved'))
      expect(page).to have_button('Order by Views')
      expect(page).to have_button('Remove selection: Unsolved')
      expect(find("#topics a:nth-child(3)")).to have_content(topic_3.title)
      expect(find("#topics a:nth-child(2)")).to have_content(topic_1.title)
      expect(find("#topics a:nth-child(1)")).to have_content(topic_2.title)
    end
  end

  context 'solution exists for a topic' do
    let!(:reply_1) { create :post, topic: topic_1, creator: student_1.user, post_number: 2 }
    let!(:reply_2) { create :post, topic: topic_1, creator: student_2.user, post_number: 3, solution: true }

    scenario "a moderator can unmark the current post as solution and mark a new solution" do
      sign_in_user(coach.user, referrer: community_path(community))

      click_link topic_1.title

      within("div#post-show-#{reply_1.id}") do
        expect(page).to_not have_selector("button[aria-label='Mark as solution']")
      end

      within("div#post-show-#{reply_2.id}") do
        accept_confirm { find("div[aria-label='Marked as solution icon']").click }
      end

      expect(page).to have_text('Reply unmarked as solution')
      dismiss_notification

      expect(reply_2.reload.solution).to eq(false)

      # change the marked solution

      within("div#post-show-#{reply_1.id}") do
        accept_confirm { find("button[aria-label='Mark as solution']").click }
      end

      dismiss_notification

      expect(reply_1.reload.solution).to eq(true)
    end
  end

  context "when the user is a coach who isn't enrolled in one of the community's connected courses" do
    before do
      CommunityCourseConnection.destroy_all
    end

    scenario "a coach from a different course can still moderate on unlinked communities" do
      sign_in_user(coach.user, referrer: community_path(community))

      click_link topic_1.title

      # Can mark a reply as solution.
      within("div#post-show-#{reply_1.id}") do
        accept_confirm { find("button[aria-label='Mark as solution']").click }
        expect(page).to have_selector("div[aria-label='Marked as solution icon']")
      end
    end
  end
end
