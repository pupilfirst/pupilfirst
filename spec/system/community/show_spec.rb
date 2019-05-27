require 'rails_helper'

feature 'Community Show' do
  include UserSpecHelper
  include FounderSpecHelper

  # Setup a course with founders and target for community.
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:level_1) { create :level, :one, course: course }
  let!(:target_group) { create :target_group, level: level_1 }
  let!(:community) { create :community, school: school }
  let!(:startup) { create :startup, level: level_1 }
  let!(:founder) { create :founder, startup: startup }
  let!(:community_course_connection) { CommunityCourseConnection.create!(course: course, community: community) }
  let!(:question_1) { create :question, community: community, creator: founder.user }
  let!(:question_2) { create :question, community: community, creator: founder.user }
  let!(:question_3) { create :question, community: community, creator: founder.user }
  let!(:answer_1) { create :answer, question: question_1, creator: founder.user }
  let(:question_title) { Faker::Lorem.sentence }
  let(:question_description) { Faker::Lorem.paragraph }

  scenario 'Active founder visits his community', js: true do
    sign_in_user(founder.user, referer: community_path(community))

    # All questions should be visible.
    expect(page).to have_text(community.name)
    expect(page).to have_text(question_1.title)
    expect(page).to have_text(question_2.title)
    expect(page).to have_text(question_3.title)
  end

  scenario 'Active founder creates a question in his community', js: true do
    sign_in_user(founder.user, referer: community_path(community))
    expect(page).to have_text(community.name)

    click_link 'Ask a question'
    expect(page).to have_text("ASK A NEW QUESTION")
    fill_in 'Title', with: question_title
    description_field = find('textarea[title="Markdown input"]')
    description_field.fill_in with: question_description
    click_button 'Post Your Question'
    expect(page).to have_text(community.name)
  end
end
