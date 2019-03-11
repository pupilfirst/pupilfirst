require 'rails_helper'

feature 'Resources' do
  let(:school) { create :school, :current }
  let(:school_2) { create :school }

  let(:course_1) { create :course, school: school }
  let(:course_2) { create :course, school: school }
  let(:level_1_c1) { create :level, :one, course: course_1 }
  let(:level_1_c2) { create :level, :one, course: course_2 }

  let(:startup) { create :startup, level: level_1_c1 }
  let(:founder) { startup.founders.first }

  let(:target_group_c1) { create :target_group, level: level_1_c1 }
  let(:target_group_c2) { create :target_group, level: level_1_c2 }

  let(:target_c1) { create :target, target_group: target_group_c1 }
  let(:target_c2) { create :target, target_group: target_group_c2 }

  let!(:public_resource) { create :resource, school: school, public: true }
  let!(:private_resource_c1) { create :resource, school: school, public: false, targets: [target_c1] }
  let!(:private_resource_c2) { create :resource, school: school, public: false, targets: [target_c2] }
  let!(:public_resource_s2) { create :resource, school: school_2, public: true }

  scenario 'public visits resources page' do
    visit resources_path

    # Visitor only sees the public resource.
    expect(page).to have_selector('.resource-box', count: 1)
    expect(page).to have_text(public_resource.title[0..25])
  end

  scenario 'public visits private resource page' do
    visit resource_path(private_resource_c1)

    expect(page).to have_content("The page you were looking for doesn't exist")
  end

  scenario 'user can download a public resource' do
    visit resource_path(public_resource)

    expect(page).to have_text(public_resource.title)
    expect(page).to have_link('Download')
  end

  context 'With a video resource' do
    let!(:public_resource) { create :resource_video_file, school: school, public: true }

    scenario 'user can stream resource' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_content(public_resource.title)
      expect(page).to have_selector('video')
    end
  end

  context 'With a video embed resource' do
    let!(:public_resource) { create :resource_video_embed, school: school, public: true }

    scenario 'user can stream video embed' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_content(public_resource.title)
      expect(page).to have_selector('iframe')
    end
  end

  context 'user is a logged-in student' do
    scenario 'Student visits resources page' do
      visit user_token_path(token: founder.user.login_token, referer: resources_path)

      # Public resources in school + private resources in course targets should be visible.
      expect(page).to have_selector('.resource-box', count: 2)
      expect(page).to have_text(public_resource.title[0..25])
      expect(page).to have_text(private_resource_c1.title[0..25])

      # Should not have access to public resource in another school.
      expect(page).not_to have_text(public_resource_s2.title[0..25])

      # Should not have access to private resource from another course (but same school).
      expect(page).not_to have_text(private_resource_c2.title[0..25])

      # Attempting to visit the show pages for such resources should 404.
      visit resource_path(public_resource_s2)
      expect(page).to have_content("The page you were looking for doesn't exist")

      visit resource_path(private_resource_c2)
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end
