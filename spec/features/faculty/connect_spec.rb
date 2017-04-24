require 'rails_helper'

feature 'Faculty Connect' do
  include UserSpecHelper

  let(:level_one) { create :level, :one }
  let(:level_two) { create :level, :two }

  let!(:faculty_1) { create :faculty, :connectable, level: level_one }
  let!(:faculty_2) { create :faculty, :connectable, level: level_two }
  let!(:faculty_3) { create :faculty }

  # Three valid connect slots for faculty 1.
  let!(:connect_slot_1) { create :connect_slot, faculty: faculty_1, slot_at: 4.days.from_now }
  let!(:connect_slot_2) { create :connect_slot, faculty: faculty_1, slot_at: 4.5.days.from_now }
  let!(:connect_slot_3) { create :connect_slot, faculty: faculty_1, slot_at: 6.days.from_now }

  # One slot for faculty 2.
  let!(:connect_slot_4) { create :connect_slot, faculty: faculty_2, slot_at: 6.days.from_now }

  # One connect request using up one of the slots for faculty 1.
  let!(:connect_request) { create :connect_request, connect_slot: connect_slot_1 }

  scenario 'User visits faculty page' do
    visit faculty_index_path

    # There should be two faculty cards.
    expect(page).to have_selector('.faculty-card', count: 3)

    # One of these cards should have a disabled connect button.
    expect(page.find('.faculty-card', text: faculty_1.name)).to have_selector('.available-marker')
    expect(page).to have_selector(".disabled.connect-link[title='Faculty Connect is only available once you are a selected founder']", count: 2)
  end

  context 'User is founder of batched-approved startup' do
    let(:startup) { create :startup }
    let(:founder) { startup.founders.where.not(id: startup.admin.id).first }

    scenario 'Founder visits faculty page' do
      sign_in_user(founder.user, referer: faculty_index_path)

      # Two of the three cards should have a disabled connect button with a special message for non-admins.
      expect(page.find('.faculty-card', text: faculty_1.name)).to have_selector('.available-marker')
      expect(page.find('.faculty-card', text: faculty_2.name)).to have_selector('.available-marker')
      expect(page).to have_selector(".disabled.connect-link[title='Faculty Connect is only available to #{startup.admin.fullname} (your team lead)']", count: 1)
      expect(page).to have_selector(".disabled.connect-link[title='To gain access to this faculty member, you need to reach Level 2!']", count: 1)
    end

    context 'Founder is admin of startup' do
      let(:founder) { startup.admin }

      context "Startup's level maxed out at two" do
        let(:startup) { create :startup, maximum_level: level_two }

        scenario 'Founder visits faculty page' do
          sign_in_user(founder.user, referer: faculty_index_path)

          # Both faculty should be available for connect now.
          expect(page).to have_selector('.connect-link[data-toggle="modal"]', count: 2)
        end
      end

      context 'Admin has a pending request with faculty' do
        let!(:connect_request) { create :connect_request, connect_slot: connect_slot_1, startup: startup }

        scenario 'Founder visits faculty page' do
          sign_in_user(founder.user, referer: faculty_index_path)

          # One of the two cards should have a disabled connect button with a special message for non-admins.
          expect(page).to have_selector('.available-marker', count: 2)
          expect(page).to have_selector(".disabled.connect-link[title='You already have a pending connect request " \
            "with this faculty member. Please write to help@sv.co if you would like to reschedule.']", count: 1)
        end
      end

      scenario 'Admin of batched-approved startup creates connect request', js: true do
        sign_in_user(founder.user, referer: faculty_index_path)

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
        expect(page).to have_selector('.connect-link.disabled')

        # Verify data.
        connect_request = startup.connect_requests.last

        expect(connect_request.questions.delete("\r")).to eq(questions)
        expect(connect_request.status).to eq(ConnectRequest::STATUS_REQUESTED)
      end
    end
  end
end
