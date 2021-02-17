require 'rails_helper'

feature 'Topic creator', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper

  # Setup a course with students and target for community.
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let!(:community) { create :community, school: school }
  let(:team) { create :team, level: level_1 }
  let(:student) { create :student, startup: team }
  let!(:topic_1) { create :topic, title: 'Foo bar', community: community }
  let!(:topic_2) { create :topic, title: 'Foobar foobaz', community: community }
  let!(:topic_3) { create :topic, title: 'Baz bar', community: community }

  before do
    create :community_course_connection, course: course, community: community
  end

  scenario 'user is shown suggestions when creating a new topic' do
    sign_in_user(student.user, referrer: new_topic_community_path(community))
    fill_in('Title', with: 'foo')

    expect(page).to have_link(topic_1.title, href: "/topics/#{topic_1.id}/foo-bar")
    expect(page).to have_link(topic_2.title, href: "/topics/#{topic_2.id}/foobar-foobaz")
    expect(page).not_to have_text(topic_3.title)

    fill_in('Title', with: ' ')

    expect(page).not_to have_text(topic_1.title)
    expect(page).not_to have_text(topic_2.title)

    fill_in('Title', with: 'BAZ')

    expect(page).to have_link(topic_3.title, href: "/topics/#{topic_3.id}/baz-bar")
    expect(page).not_to have_text(topic_1.title)
    expect(page).not_to have_text(topic_2.title)
  end

  context 'community has topic categories' do
    let!(:category_1) { create :topic_category, community: community }
    let!(:category_2) { create :topic_category, community: community }

    scenario 'users selects a category while creating a topic' do
      sign_in_user(student.user, referrer: new_topic_community_path(community))

      topic_title = Faker::Lorem.sentence
      fill_in('Title', with: topic_title)
      select category_2.name, from: 'topic_category'
      add_markdown 'topic body'

      click_button 'Create Topic'

      within("div[aria-label='Topic Details']") do
        expect(page).to have_text(category_2.name)
      end

      new_topic = community.topics.find_by(title: topic_title)

      expect(new_topic.topic_category).to eq(category_2)
    end
  end

  context 'when personal coaches are assigned' do
    let(:coach_1) { create :faculty, school: school }
    let(:coach_2) { create :faculty, school: school }

    before do
      create :faculty_course_enrollment, faculty: coach_1, course: course
      create :faculty_startup_enrollment, faculty: coach_2, startup: student.startup
    end

    scenario 'when user creates a new topic' do
      sign_in_user(student.user, referrer: new_topic_community_path(community))

      topic_title = Faker::Lorem.sentence
      fill_in('Title', with: topic_title)
      add_markdown 'topic body'
      click_button 'Create Topic'

      expect(page).to have_text('Unsubscribe')

      new_topic = community.topics.find_by(title: topic_title)

      # Personal coaches must already be subscribed to the new topic.
      expect(new_topic.subscribers.pluck(:id)).to contain_exactly(coach_2.user.id, student.user.id)

      # Notifications should have been created for this new topic.
      expect(Notification.last.notifiable).to eq(new_topic)
    end
  end
end
