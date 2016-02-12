require 'rails_helper'

feature 'Faculty Connect' do
  let!(:faculty_1) { create :faculty }
  let!(:faculty_2) { create :faculty }

  # Three valid connect slots
  let!(:connect_slot_1) { create :connect_slot, faculty: faculty_1, slot_at: 4.days.from_now }
  let!(:connect_slot_2) { create :connect_slot, faculty: faculty_1, slot_at: 4.5.days.from_now }
  let!(:connect_slot_3) { create :connect_slot, faculty: faculty_1, slot_at: 6.days.from_now }

  # One connect request using up one of the slots.
  let!(:connect_request) { create :connect_request, connect_slot: connect_slot_1 }

  scenario 'User visits faculty page' do
    visit faculty_index_path

    # There should be two faculty cards.
    expect(page).to have_selector('.faculty-card', count: 2)

    # One of these cards should have a disabled connect button.
    expect(page.find('.faculty-card', text: faculty_1.name)).to have_selector('.available-marker', count: 1)
    expect(page).to have_selector(".disabled.connect-link[title='Faculty Connect is only available once you are a selected founder']", count: 1)
  end

  context 'User is founder of batched-approved startup' do
    let(:user) { create :founder_with_password, confirmed_at: Time.now }
    let(:batch) { create :batch }
    let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED, batch: batch }

    before :each do
      # Add user as founder of startup.
      startup.founders << user

      # Log in the user.
      visit new_user_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_on 'Sign in'
    end

    scenario 'Founder visits faculty page' do
      visit faculty_index_path

      # One of the two cards should have a disabled connect button with a special message for non-admins.
      expect(page.find('.faculty-card', text: faculty_1.name)).to have_selector('.available-marker', count: 1)
      expect(page).to have_selector(".disabled.connect-link[title='Faculty Connect is only available to #{startup.admin.fullname} (your team lead)']", count: 1)
    end

    context 'Founder is admin of startup' do
      before :all do
        # Let URL requests through to allow JS test to work.
        WebMock.allow_net_connect!
      end

      after :all do
        # Lock it down again.
        WebMock.disable_net_connect!
      end

      before :each do
        # Make our 'user' the admin.
        startup.admin.update(startup_admin: false)
        user.update(startup_admin: true)
      end

      context 'Admin has a pending request with faculty' do
        let!(:connect_request) { create :connect_request, connect_slot: connect_slot_1, startup: startup }

        scenario 'Founder visits faculty page' do
          visit faculty_index_path

          # One of the two cards should have a disabled connect button with a special message for non-admins.
          expect(page.find('.faculty-card', text: faculty_1.name)).to have_selector('.available-marker', count: 1)
          expect(page).to have_selector(".disabled.connect-link[title='You already have a pending connect request " \
            "with this faculty member. Please write to help@sv.co if you would like to reschedule.']", count: 1)
        end
      end

      scenario 'Admin of batched-approved startup creates connect request', js: true do
        visit faculty_index_path

        page.find('a.connect-link').click

        click_on 'Submit Request'

        # Attempting to submit the form without writing questions should show error.
        expect(page.find('.form-group.connect_request_questions')[:class].split).to include('has-error')

        # Fill something in as questions.
        questions = Faker::Lorem.words(rand(10)).join(' ') + "\n\n" + Faker::Lorem.words(rand(10)).join(' ')
        fill_in 'connect_request_questions', with: questions

        click_on 'Submit Request'

        # The connect button should now be disabled.
        expect(page.find('.connect-link')[:class]).to include('disabled')

        # Verify data.
        connect_request = startup.connect_requests.last

        expect(connect_request.questions.delete("\r")).to eq(questions)
        expect(connect_request.status).to eq(ConnectRequest::STATUS_REQUESTED)
      end
    end
  end
end
