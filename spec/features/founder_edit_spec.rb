require 'rails_helper'

include UserSpecHelper

feature 'Founder Edit' do
  let(:startup) { create :startup, :subscription_active }
  let(:founder) { create :founder, college: nil, college_text: 'Anon College of Engineering' }
  let(:new_founder_name) { Faker::Name.name }

  before do
    startup.founders << founder
  end

  context 'Active founder visits edit page of his profile' do
    before :each do
      # Log in the founder.
      sign_in_user(founder.user, referer: edit_founder_path)
      # founder should now be on his profile edit page.
    end

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

  context 'Exited founder attempts to edit his profile' do
    before do
      founder.update!(exited: true)
      sign_in_user(founder.user)
    end

    scenario 'founder visits the edit page', js: true do
      visit edit_founder_path
      expect(page).to have_text('not an active founder anymore')
    end
  end

  context 'Founder with inactive subscription attempts to edit his profile' do
    let(:startup) { create :startup }

    scenario 'founder visits the edit page' do
      # Create a pending payment.
      create :payment, startup: startup

      sign_in_user(founder.user, referer: edit_founder_path)
      expect(page).to have_content('Please pay the membership fee for the next month.')
    end
  end
end
