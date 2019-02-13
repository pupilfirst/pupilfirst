require 'rails_helper'

feature 'Office Hour' do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:founder) { startup.founders.first }
  let(:faculty) { create :faculty, school: startup.school, public: true }
  let(:unenrolled_faculty) { create :faculty, school: startup.school, public: true }
  let(:enrolled_hidden_faculty) { create :faculty, school: startup.school, public: false }

  let!(:faculty_enrollment) { create :faculty_course_enrollment, faculty: faculty, course: startup.course }
  let!(:hidden_faculty_enrollment) { create :faculty_course_enrollment, faculty: enrolled_hidden_faculty, course: startup.course }

  before do
    # Create connect slots for all faculty.
    [faculty, unenrolled_faculty].each do |f|
      create :connect_slot, faculty: f, slot_at: 5.days.from_now
      create :connect_slot, faculty: f, slot_at: 6.days.from_now
    end
  end

  scenario 'User visits faculty page' do
    visit coaches_index_path

    # There should be a single faculty card.
    expect(page).to have_selector('.faculty-card', count: 2)

    # There should be no connect link on the page, since user isn't signed in.
    expect(page).not_to have_selector('.connect-link')
  end

  context 'When the user is a signed in founder' do
    context 'Team has a pending request with faculty' do
      let!(:connect_request) { create :connect_request, connect_slot: faculty.connect_slots.first, startup: startup }

      scenario 'Founder visits faculty page' do
        sign_in_user(founder.user, referer: coaches_index_path)

        # One of the cards should have disabled connect buttons with a special message.
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
