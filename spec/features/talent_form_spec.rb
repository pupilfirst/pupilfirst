require 'rails_helper'

feature 'Talent Form' do
  include_context 'allow_temporary_net_connect'

  context 'User visits talent page' do
    before :each do
      visit talent_path
    end
    scenario 'User submits form for acquiring teams', js: true do
      # ensure user is on talent page without the talent form
      expect(page).to have_text('Discover Great Startups')

      click_button 'Acquihire Teams'
      expect(page.find('#talent_query_type_acquihiring_teams')).to be_checked

      fill_in 'Name', with: 'Some Name'
      fill_in 'Email address', with: 'something@example.com'
      fill_in 'Mobile number', with: '9876543210'
      fill_in 'Organization', with: 'Some Company Name'
      fill_in 'Website', with: 'www.example.com'
      click_on 'Submit'

      open_email('help@sv.co')

      expect(current_email.subject).to include('Talent Form: Acquihiring Teams (by Some Name)')
      expect(current_email.body).to include('Some Name')
      expect(current_email.body).to include('something@example.com')
      expect(current_email.body).to include('9876543210')
      expect(current_email.body).to include('Some Company Name')
      expect(current_email.body).to include('www.example.com')
    end
  end
end
