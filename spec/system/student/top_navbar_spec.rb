require 'rails_helper'

feature 'Student Top Navbar', js: true do
  include UserSpecHelper

  context 'when there is at least one featured coach' do
    let!(:coach) { create :faculty, public: true }

    scenario 'a visitor comes to the homepage' do
      visit root_path

      expect(page).to have_link('Coaches', href: '/coaches')
    end
  end
end
