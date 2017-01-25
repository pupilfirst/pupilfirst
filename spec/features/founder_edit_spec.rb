require 'rails_helper'

feature 'Founder Edit' do
  let(:founder) { create :founder }
  let(:new_founder_name) { Faker::Name.name }

  before :each do
    # Log in the founder.

    visit user_token_url(token: founder.user.login_token, referer: edit_founder_path)

    # founder should now be on his profile edit page.
  end

  context 'Founder visits edit page of his profile' do
    scenario 'Founder tries to submit a blank form' do
      expect(page).to have_text('Editing').and have_text('profile')
      fill_in 'founders_edit_name', with: ''
      fill_in 'founders_edit_born_on', with: ''
      fill_in 'founders_edit_phone', with: ''
      fill_in 'founders_edit_communication_address', with: ''
      click_on 'Update details'

      expect(page).to have_text("can't be blank", count: 5)
    end

    scenario 'Founder fills in the required fields and submits' do
      expect(page).to have_text('Editing').and have_text('profile')
      fill_in 'founders_edit_name', with: new_founder_name
      fill_in 'founders_edit_born_on', with: '1997-01-15'
      fill_in 'founders_edit_phone', with: '9876543210'
      fill_in 'founders_edit_communication_address', with: '37623 Gutmann MountainNorth Adelinetown25858-7040'
      select "My college isn't listed", from: 'founders_edit_college_id'
      click_on 'Update details'

      expect(page).to have_text(new_founder_name)
      expect(page).to have_link('Complete Your Profile')
      expect(page).to have_selector('div.activity-section')
    end
  end
end
