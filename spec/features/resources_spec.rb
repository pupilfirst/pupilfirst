require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Resources' do
  include AjaxHelpers

  let(:user) { create :user_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  let!(:tet_one_liner) { create :tet_one_liner }
  let!(:tet_new_product_deck) { create :tet_new_product_deck }
  let!(:tet_team_formed) { create :tet_team_formed }

  let!(:public_resource_1) { create :resource }
  let!(:public_resource_2) { create :resource }
  let!(:approved_resource_for_all) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED }
  let!(:approved_resource_for_batch_1) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, shared_with_batch: 1 }
  let!(:approved_resource_for_batch_2) { create :resource, share_status: Resource::SHARE_STATUS_APPROVED, shared_with_batch: 2 }

  before :all do
    WebMock.allow_net_connect!
  end

  after :all do
    WebMock.disable_net_connect!
  end

  scenario 'User visits resources page' do
    visit resources_path

    expect(page).to have_selector('.resource', count: 2)
    expect(page).to have_text(public_resource_1.title)
    expect(page).to have_text(public_resource_2.title)
  end

  scenario 'User visits resource page' do
    visit resources_path
    expect(page).to have_text('Approved Startups get access to exclusive content produced by Faculty')
  end

  scenario 'User downloads resource', js: true do
    visit resources_path

    new_window = window_opened_by { click_on 'Download', match: :first }
    wait_for_ajax

    within_window new_window do
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
    end
  end

  context 'With a video resource' do
    let!(:public_resource_2) { create :video_resource }

    scenario 'User can stream resource' do
      visit resources_path

      page.find('.stream-resource').click

      expect(page).to have_selector('video')
    end
  end

  context 'User is a logged in founder' do
    before :each do
      # Make the user a founder of approved startup.
      startup.founders << user

      # Login the user.
      visit new_user_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_on 'Sign in'
    end

    context "Founder's startup is not approved" do
      let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_PENDING }

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
        let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED, batch_number: 1 }

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
