require 'rails_helper'

feature 'SA Communities Editor' do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course_1) { create :course, school: school }
  let!(:course_2) { create :course, school: school }
  let!(:community_1) { create :community, school: school }
  let!(:community_2) { create :community, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:new_community_name) { Faker::Lorem.words(2).join ' ' }
  let!(:new_community_name_for_edit) { Faker::Lorem.words(2).join ' ' }

  before do
    # Create a domain for school
    create :domain, :primary, school: school
  end

  scenario 'school admin visits a community editor', js: true do
    sign_in_user school_admin.user, referer: school_communities_path

    # list all communities
    expect(page).to have_text("Add New Community")
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)

    # Add a new Community
    click_button 'Add New Community'
    fill_in 'Name', with: new_community_name
    click_button 'Create a new community'
    expect(page).to have_text("Community created successfully")
    dismiss_notification

    expect(page).to have_text(new_community_name)
    community = Community.where(name: new_community_name).first
    expect(community.target_linkable).to eq(false)
    expect(community.courses).to eq([])

    # Edit Community
    find("a", text: new_community_name).click
    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_2.name)
    fill_in 'Name', with: new_community_name_for_edit, fill_options: { clear: :backspace }
    click_button 'Yes'
    find("div[title=\"#{course_1.name} Course\"]").click
    click_button 'Update Community'
    expect(page).to have_text("Community updated successfully")

    community.reload
    expect(community.target_linkable).to eq(true)
    expect(community.courses).to eq([course_1])
  end
end
