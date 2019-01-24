require 'rails_helper'

feature 'Office Hour' do
  include UserSpecHelper

  let!(:faculty) { create :faculty }

  # Three valid connect slots for faculty 1.
  let!(:connect_slot_1) { create :connect_slot, faculty: faculty, slot_at: 4.days.from_now }
  let!(:connect_slot_2) { create :connect_slot, faculty: faculty, slot_at: 4.5.days.from_now }
  let!(:connect_slot_3) { create :connect_slot, faculty: faculty, slot_at: 6.days.from_now }

  # One connect request using up one of the slots for faculty 1.
  let!(:connect_request) { create :connect_request, connect_slot: connect_slot_1 }

  scenario 'User visits faculty page' do
    visit coaches_index_path

    # There should be three faculty cards.
    expect(page).to have_selector('.faculty-card', count: 1)

    # Two of these cards should have disabled connect buttons.
    expect(page.find('.faculty-card', text: faculty.name)).to have_selector('.available-marker')
    expect(page).to have_selector(".disabled.connect-link[title='Office hours are only available to active students']", count: 1)
  end

  context 'User is founder of approved startup' do
    let(:startup) { create :startup, :subscription_active }
    let(:founder) { startup.founders.where.not(id: startup.founders.first.id).first }

    context 'Team has a pending request with faculty' do
      let!(:connect_request) { create :connect_request, connect_slot: connect_slot_1, startup: startup }

      scenario 'Founder visits faculty page' do
        sign_in_user(founder.user, referer: coaches_index_path)

        # Two cards should have disabled connect buttons with a special message.
        expect(page).to have_selector('.available-marker', count: 1)
        expect(page).to have_selector(".disabled.connect-link[title='You already have a pending office hour request " \
            "with this coach. Please write to help@sv.co if you would like to reschedule.']", count: 1)
      end
    end

    scenario 'Founder creates connect request', js: true do
      sign_in_user(founder.user, referer: coaches_index_path)

      expect(page).to have_selector('.connect-link[data-toggle="modal"]', count: 1)

      page.find('.connect-link[data-toggle="modal"]').click

      # Fill something in as questions.
      questions = <<~QUESTIONS
        These are the questions I have:

        1. This is question number 1.
        2. This is question number two with a single special character: ₹
        3. ഈ ചോദ്യം മലയാളത്തിൽ ആണ്
      QUESTIONS

      fill_in 'connect_request_questions', with: questions
      click_on 'Submit Request'

      # The connect button should now be disabled.
      #
      # data-original-title is used here instead of the title prop because Bootstrap tooltip modifies the element.
      expect(page).to have_selector(".disabled.connect-link[data-original-title='You already have a pending office hour request with this coach. Please write to help@sv.co if you would like to reschedule.']", count: 1)

      # Verify data.
      connect_request = startup.connect_requests.last

      expect(connect_request.questions.delete("\r")).to eq(questions)
      expect(connect_request.status).to eq(ConnectRequest::STATUS_REQUESTED)
    end
  end
end
