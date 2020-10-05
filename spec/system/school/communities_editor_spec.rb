require 'rails_helper'

feature 'SA Communities Editor', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course_1) { create :course, school: school }
  let!(:course_2) { create :course, school: school }
  let!(:community_1) { create :community, school: school }
  let!(:community_2) { create :community, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:new_community_name) { Faker::Lorem.words(number: 2).join ' ' }
  let!(:new_community_name_for_edit) { Faker::Lorem.words(number: 2).join ' ' }

  scenario 'school admin visits a community editor' do
    sign_in_user school_admin.user, referrer: school_communities_path

    # list all communities
    expect(page).to have_text("Add New Community")
    expect(page).to have_text(community_1.name)
    expect(page).to have_text(community_2.name)

    # Add a new Community
    click_button 'Add New Community'
    fill_in 'What do you want to call this community?', with: new_community_name
    click_button 'Create Community'

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

    fill_in 'What do you want to call this community?', with: new_community_name_for_edit
    click_button 'Yes'
    find("div[title=\"Select #{course_1.name}\"]").click
    click_button 'Update Community'

    expect(page).to have_text("Community updated successfully")

    expect(community.reload.target_linkable).to eq(true)
    expect(community.courses).to eq([course_1])
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_communities_path
    expect(page).to have_text("Please sign in to continue.")
  end

  context 'when some communities have existing topic categories' do
    let!(:category_1) { create :topic_category, community: community_2 }
    let!(:category_2) { create :topic_category, community: community_2 }
    let!(:category_3) { create :topic_category, community: community_2 }
    let!(:topic_in_category_2) { create :topic, community: community_2, topic_category: category_2 }

    scenario 'user adds new categories to a community without categories' do
      sign_in_user school_admin.user, referrer: school_communities_path

      find("a", text: community_1.name).click

      expect(page).to have_text('There are currently no topic categories in this community!')

      click_button 'Add Categories'

      expect(page).to have_text("Categories in #{community_1.name}".upcase)
      expect(page).to_not have_button('Save Category')

      fill_in 'add-new-category', with: 'New Category'

      click_button 'Save Category'

      expect(page).to have_text('0 topics')

      expect(community_1.reload.topic_categories.count).to eq(1)
      expect(community_1.topic_categories.first.name).to eq('New Category')
    end

    scenario 'user modifies existing categories in community' do
      sign_in_user school_admin.user, referrer: school_communities_path

      find("a", text: community_2.name).click

      expect(page).to have_text(category_1.name)

      click_button 'Edit Categories'

      expect(page).to have_text("Categories in #{community_2.name}".upcase)

      # Updates existing category name
      expect(page).to_not have_button('Update Category')

      within("div[aria-label='Editor for category #{category_1.id}']") do
        fill_in 'category-name', with: 'new name'
        click_button 'Update Category'
      end

      within("div[aria-label='Editor for category #{category_1.id}']") do
        expect(page).to have_text('0 topics')
      end

      expect(category_1.reload.name).to eq('new name')
      expect(community_2.reload.topic_categories.count).to eq(3)

      # Deletes a category without topics

      within("div[aria-label='Editor for category #{category_1.id}']") do
        expect(page).to have_text('0 topics')
        find("button[title='Delete Category").click
      end

      expect(page).to have_selector('.topic-category-editor', count: 2)
      expect(community_2.reload.topic_categories.count).to eq(2)
      expect(TopicCategory.find_by(id: category_1.id)).to eq(nil)

      # Deletes an existing category with topics

      within("div[aria-label='Editor for category #{category_2.id}']") do
        expect(page).to have_text('1 topic')
        accept_confirm do
          find("button[title='Delete Category").click
        end
      end

      expect(page).to have_selector('.topic-category-editor', count: 1)

      expect(community_2.reload.topic_categories.count).to eq(1)
      expect(TopicCategory.find_by(id: category_2.id)).to eq(nil)
      expect(topic_in_category_2.reload.topic_category_id).to eq(nil)
    end

    scenario 'user closes category editor with unsaved changes' do
      sign_in_user school_admin.user, referrer: school_communities_path

      find("a", text: community_2.name).click

      expect(page).to have_text(category_1.name)

      click_button 'Edit Categories'

      expect(page).to have_text("Categories in #{community_2.name}".upcase)

      # Dirty new category form

      fill_in 'add-new-category', with: 'some name'

      accept_confirm do
        click_button 'Close Category Editor'
      end

      click_button 'Edit Categories'

      # Dirty update category form

      within("div[aria-label='Editor for category #{category_1.id}']") do
        fill_in 'category-name', with: 'new name'
      end

      accept_confirm do
        click_button 'Close Category Editor'
      end
    end
  end
end
