require 'rails_helper'

feature 'Faculty Weekly Slots' do
  let!(:faculty) { create :faculty }

  before :all do
    WebMock.allow_net_connect!
  end

  after :all do
    WebMock.disable_net_connect!
  end

  context 'User hits weekly slots page url' do
    scenario 'User uses a random token identifier' do
      visit weekly_slots_faculty_index_path(SecureRandom.base58(24))

      expect(page).to have_text("The page you were looking for doesn't exist.")
      expect(page).to have_text('You may have mistyped the address, or the page may have moved.')
    end

    scenario 'User uses the token of a faculty without email' do
      faculty.update(email: nil)
      visit weekly_slots_faculty_index_path(faculty.token)

      expect(page).to have_text("The page you were looking for doesn't exist.")
      expect(page).to have_text('You may have mistyped the address, or the page may have moved.')
    end

    scenario 'User uses the correct token of a valid faculty with no connection slots' do
      visit weekly_slots_faculty_index_path(faculty.token)
      expect(page).to have_text("Slots for #{faculty.name}")
      expect(page).to have_text("You current commitment is 0 minutes.")
    end
  end

  context 'User visits weekly_slot page of faculty with connection slots', js: true do
    let!(:connection_slot_1) { create :connect_slot, faculty: faculty, slot_at: ConnectSlot.next_week_start + 7.hours }
    let!(:connection_slot_2) { create :connect_slot, faculty: faculty, slot_at: ConnectSlot.next_week_start + 32.hours }
    scenario 'User verifies present commitment' do
      visit weekly_slots_faculty_index_path(faculty.token)
      expect(page).to have_text("Slots for #{faculty.name}")
      expect(page).to have_text("You current commitment is 40 minutes.")
      expect(page).to have_selector('.connect-slot.selected', count: 1)
      expect(page.find('.connect-slot.selected', match: :first)).to have_text('07:00')

      click_on 'Tue'
      expect(page.find('li.active')).to have_text('Tue')
      expect(page).to have_selector('.connect-slot.selected', count: 1)
      expect(page.find('.connect-slot.selected', match: :first)).to have_text('08:00')
    end
  end
end
