require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Resources' do
  include AjaxHelpers

  let(:founder) { create :founder_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup }

  let!(:public_resource_1) { create :resource }
  let!(:public_resource_2) { create :resource }

  let(:batch_1) { create :batch }
  let(:batch_2) { create :batch }

  let!(:approved_resource_for_all) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED }
  let!(:approved_resource_for_batch_1) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, batch: batch_1 }
  let!(:approved_resource_for_batch_2) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, batch: batch_2 }

  before :all do
    WebMock.allow_net_connect!
    PublicSlackTalk.mock = true
  end

  after :all do
    WebMock.disable_net_connect!
    PublicSlackTalk.mock = false
  end

  scenario 'founder visits resources page' do
    visit resources_path

    expect(page).to have_selector('.resource', count: 2)
    expect(page).to have_text(public_resource_1.title)
    expect(page).to have_text(public_resource_2.title)
  end

  scenario 'founder visits resource page' do
    visit resources_path
    expect(page).to have_text('Approved Startups get access to exclusive content produced by Faculty')
  end

  scenario 'founder downloads resource', js: true do
    visit resources_path

    new_window = window_opened_by { click_on 'Download', match: :first }
    wait_for_ajax

    within_window new_window do
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
    end
  end

  context 'With a video resource' do
    let!(:public_resource_2) { create :video_resource }

    scenario 'founder can stream resource' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_selector('video')
    end
  end

  context 'founder is a logged in founder' do
    before :each do
      # Make the founder a founder of approved startup.
      startup.founders << founder

      # Login the founder.
      visit new_founder_session_path
      fill_in 'founder_email', with: founder.email
      fill_in 'founder_password', with: 'password'
      click_on 'Sign in'
    end

    context "Founder's startup is not approved" do
      let(:startup) { create :startup, dropped_out: true }

      scenario 'Founder visits resources page' do
        visit resources_path

        expect(page).to have_selector('.resource', count: 2)
        expect(page).to have_text(public_resource_1.title)
        expect(page).to have_text(public_resource_2.title)
      end

      scenario 'Founder visits approved resource page' do
        visit resource_path(approved_resource_for_all)
        expect(page.status_code).to eq(404)
      end
    end

    context "Founder's startup is approved" do
      scenario 'Founder visits resources page' do
        visit resources_path

        expect(page).to have_text('Please do not share these resources outside your founding team')
        expect(page).to have_selector('.resource', count: 3)
        expect(page).to have_text(public_resource_1.title)
        expect(page).to have_text(public_resource_2.title)
        expect(page).to have_text(approved_resource_for_all.title)
      end

      context "Founder's startup is from batch 1" do
        let(:startup) { create :startup, batch: batch_1 }

        scenario 'Founder visits resources page' do
          visit resources_path

          expect(page).to have_selector('.resource', count: 4)
          expect(page).to have_text(public_resource_1.title)
          expect(page).to have_text(public_resource_2.title)
          expect(page).to have_text(approved_resource_for_all.title)
          expect(page).to have_text(approved_resource_for_batch_1.title)
        end

        scenario 'Founder visits approved resource for batch 1 page' do
          visit resource_path(approved_resource_for_batch_1)
          expect(page).to have_text(approved_resource_for_batch_1.title)
        end

        scenario 'Founder visits approved resource for batch 2 page' do
          visit resource_path(approved_resource_for_batch_2)
          expect(page.status_code).to eq(404)
        end
      end

      scenario 'Founder visits approved resource page' do
        visit resource_path(approved_resource_for_all)
        expect(page).to have_text(approved_resource_for_all.title)
      end
    end
  end
end
