require 'rails_helper'

feature 'Topic creator', js: true do
  include UserSpecHelper

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
    sign_in_user(student.user, referer: new_topic_community_path(community))
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
end
