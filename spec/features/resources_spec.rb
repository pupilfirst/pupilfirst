require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Resources' do
  let(:course_1) { create :course }
  let(:course_2) { create :course }
  let(:level_0) { create :level, :zero, course: course_1 }
  let(:level_1) { create :level, :one, course: course_1 }
  let(:level_2) { create :level, :two, course: course_1 }
  let(:level_1_s2) { create :level, :one, course: course_2 }
  let(:level_2_s2) { create :level, :two, course: course_2 }

  let(:founder) { create :founder }
  let(:startup) { create :startup, :subscription_active, level: level_1 }

  let!(:public_resource) { create :resource }
  let!(:level_0_resource) { create :resource, level: level_0 }
  let!(:level_1_resource) { create :resource, level: level_1 }
  let!(:level_2_resource) { create :resource, level: level_2 }
  let!(:l1_s2_resource) { create :resource, level: level_1_s2 }
  let!(:l2_s2_resource) { create :resource, level: level_2_s2 }

  scenario 'user visits resources page' do
    visit resources_path

    # user only sees the public resource
    expect(page).to have_selector('.resource-box', count: 1)
    expect(page).to have_text(public_resource.title[0..10])
  end

  scenario 'user visits restricted resource page' do
    visit resource_path(level_0_resource)
    expect(page).to have_text('Approved teams get access to exclusive content produced by our coaches')
  end

  scenario 'user can download public resource' do
    visit resource_path(public_resource)

    expect(page).to have_text(public_resource.title)
    expect(page).to have_link('Download')
  end

  context 'With a video resource' do
    let!(:public_resource_2) { create :resource_video_file }

    scenario 'user can stream resource' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_selector('video')
    end
  end

  context 'With a video embed resource' do
    let!(:public_video_embed_resource) { create :resource_video_embed }

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

    context "Founder's startup is not approved" do
      before do
        startup.update!(dropped_out: true)
      end

      scenario 'Founder visits resources page' do
        visit resources_path
        # only public resource is visible
        expect(page).to have_selector('.resource-box', count: 1)
        expect(page).to have_text(public_resource.title[0..10])
      end

      scenario 'Founder visits level 0 resource page' do
        visit resource_path(level_0_resource)
        # should be redirected to the index page
        expect(page).to have_text('This is just a small sample of resources available in the SV.CO Library')
      end
    end

    context "Founder's startup is approved" do
      scenario 'Founder visits resources page' do
        visit resources_path

        expect(page).to have_text('Please do not share these resources outside your founding team')

        # public resources + resources upto his level should be shown
        expect(page).to have_selector('.resource-box', count: 4)
        expect(page).to have_text(public_resource.title[0..10])
        expect(page).to have_text(level_0_resource.title[0..10])
        expect(page).to have_text(level_1_resource.title[0..10])
        expect(page).to have_text(level_2_resource.title[0..10])

        # Should not have access to resource in course 2.
        visit resource_path(l2_s2_resource)
        # should be redirected to the index page
        expect(page).to have_text('Please do not share these resources outside your founding team')
      end

      context "founder is in second course" do
        let(:startup) { create :startup, :subscription_active, level: level_2_s2 }

        scenario 'Founder visits resources page' do
          visit resources_path

          expect(page).to have_text('Please do not share these resources outside your founding team')

          # Public resources + resources in course 2 should be shown. Resources from course 1 should not be visible.
          expect(page).to have_selector('.resource-box', count: 3)
          expect(page).to have_text(public_resource.title[0..10])
          expect(page).not_to have_text(level_0_resource.title[0..10])
          expect(page).not_to have_text(level_1_resource.title[0..10])
          expect(page).not_to have_text(level_2_resource.title[0..10])
          expect(page).to have_text(l1_s2_resource.title[0..10])
          expect(page).to have_text(l2_s2_resource.title[0..10])

          # Should not have access to resource in course 1.
          visit resource_path(level_2_resource)
          # should be redirected to the index page
          expect(page).to have_text('Please do not share these resources outside your founding team')
        end
      end
    end
  end
end
