require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Resources' do
  let(:level_0) { create :level, :zero }
  let(:level_1) { create :level, :one }
  let(:level_2) { create :level, :two }

  let(:founder) { create :founder }
  let(:startup) { create :startup, :subscription_active }

  let!(:public_resource) { create :resource }
  let!(:level_0_resource) { create :resource, level: level_0 }
  let!(:level_1_resource) { create :resource, level: level_1 }
  let!(:level_2_resource) { create :resource, level: level_2 }

  scenario 'user visits resources page' do
    visit resources_path

    # user only sees the public resource
    expect(page).to have_selector('.resource-box', count: 1)
    expect(page).to have_text(public_resource.title[0..10])
  end

  scenario 'user visits restricted resource page' do
    visit resource_path(level_0_resource)
    expect(page).to have_text('Approved teams get access to exclusive content produced by Faculty')
  end

  scenario 'user can download public resource' do
    visit resource_path(public_resource)

    expect(page).to have_text(public_resource.title)
    expect(page).to have_link('Download')
  end

  context 'With a video resource' do
    let!(:public_resource_2) { create :video_resource }

    scenario 'user can stream resource' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_selector('video')
    end
  end

  context 'With a video embed resource' do
    let!(:video_embed_code) { '<iframe src="https://www.youtube.com/sample"></iframe>' }
    let!(:public_video_embed_resource) { create :resource, file: nil, video_embed: video_embed_code }

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
        expect(page).to have_text('Please do not share these resources outside your founding team')

        # public resources + resources upto his level should be shown
        expect(page).to have_selector('.resource-box', count: 3)
        expect(page).to have_text(public_resource.title[0..10])
        expect(page).to have_text(level_0_resource.title[0..10])
        expect(page).to have_text(level_1_resource.title[0..10])
      end
    end
  end
end
