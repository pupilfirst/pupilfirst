require 'rails_helper'

feature 'Resources' do
  let(:school) { create :school, :current }
  let(:school_2) { create :school }
  let(:course_1) { create :course, school: school }
  let(:course_2) { create :course, school: school }
  let(:level_0) { create :level, :zero, course: course_1 }
  let(:level_1) { create :level, :one, course: course_1 }
  let(:level_2) { create :level, :two, course: course_1 }
  let(:level_1_s2) { create :level, :one, course: course_2 }
  let(:level_2_s2) { create :level, :two, course: course_2 }

  let(:founder) { create :founder }
  let(:startup) { create :startup, level: level_1 }

  let!(:public_resource) { create :resource, school: school, public: true }
  let!(:level_0_resource) { create :resource, school: school, public: false }
  let!(:level_1_resource) { create :resource, school: school, public: false }
  let!(:level_2_resource) { create :resource, school: school, public: false }
  let!(:l1_s2_resource) { create :resource, school: school, public: false }
  let!(:l2_s2_resource) { create :resource, school: school, public: false }
  let!(:school_2_resource) { create :resource, school: school_2, public: true }

  scenario 'user visits resources page without signing in' do
    visit resources_path

    # user only sees the public resource
    expect(page).to have_selector('.resource-box', count: 1)
    expect(page).to have_text(public_resource.title[0..25])
  end

  scenario 'user visits restricted resource page' do
    visit resource_path(level_0_resource)
    expect(page).to have_text('Approved teams get access to exclusive content produced by our coaches')
  end

  scenario 'user can download a public resource' do
    visit resource_path(public_resource)

    expect(page).to have_text(public_resource.title)
    expect(page).to have_link('Download')
  end

  context 'With a video resource' do
    let!(:public_resource_2) { create :resource_video_file, school: school, public: true }

    scenario 'user can stream resource' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_selector('video')
    end
  end

  context 'With a video embed resource' do
    let!(:public_video_embed_resource) { create :resource_video_embed, school: school, public: true }

    scenario 'user can stream video embed' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_selector('iframe')
    end
  end

  context 'founder is a logged in founder' do
    before :each do
      # Make the founder a founder of approved startup.
      startup.founders << founder

      # Log in the founder.
      visit user_token_path(token: founder.user.login_token, referer: resources_path)
    end

    context "Founder's startup is in a school" do
      scenario 'Founder visits resources page' do
        visit resources_path

        expect(page).to have_text('Please do not share these resources outside your founding team')

        # public resources + resources upto his level should be shown
        expect(page).to have_selector('.resource-box', count: 6)
        expect(page).to have_text(public_resource.title[0..25])
        expect(page).to have_text(level_0_resource.title[0..25])
        expect(page).to have_text(level_1_resource.title[0..25])
        expect(page).to have_text(level_2_resource.title[0..25])
        expect(page).to have_text(l1_s2_resource.title[0..25])
        expect(page).to have_text(l2_s2_resource.title[0..25])

        # Should not have access to resource in another school.
        visit resource_path(school_2_resource)

        # Should be redirected to the index page.
        expect(page).to have_text('Please do not share these resources outside your founding team')
      end
    end
  end
end
