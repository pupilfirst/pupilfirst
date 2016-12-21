require 'rails_helper'

feature 'Startup Edit' do
  let(:founder) { create :founder }
  let(:co_founder) { create :founder }
  let!(:startup) { create :startup }

  let(:new_product_name) { Faker::Lorem.words(rand(3) + 1).join ' ' }
  let(:new_product_description) { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
  let(:new_deck) { Faker::Internet.domain_name }

  before :each do
    # Add founder as founder of startup.
    startup.founders << founder

    # Log in the founder.
    visit user_token_url(token: founder.user.login_token, referer: edit_founder_startup_path)

    # founder should now be on his startup edit page.
  end

  context 'Founder visits edit page of his startup' do
    scenario 'Founder updates all required fields' do
      fill_in 'startup_product_name', with: new_product_name
      fill_in 'startup_product_description', with: new_product_description
      fill_in 'startup_presentation_link', with: new_deck

      click_on 'Update startup profile'

      # Wait for page to load before checking database.
      expect(page).to have_content(new_product_name)

      startup.reload

      expect(startup.product_name).to eq(new_product_name)
      expect(startup.product_description).to eq(new_product_description)
      expect(startup.presentation_link).to eq(new_deck)
    end

    scenario 'Founder clears all required fields' do
      fill_in 'startup_product_name', with: ''
      click_on 'Update startup profile'

      expect(page).to have_text('Please review the problems below')
      expect(page).to have_selector('div.form-group.startup_product_name.has-error')
    end

    scenario 'Non-admin founder views delete startup section' do
      expect(page).to have_text('Only the team leader can delete a startup\'s profile')
    end

    scenario 'Founder looks to delete his approved startup as startup_admin' do
      # change startup admin to this founder
      startup.admin.update(startup_admin: false)
      founder.update(startup_admin: true)
      startup.reload
      founder.reload

      visit edit_founder_startup_path
      expect(page).to have_text('To delete your startup timeline, contact your SV.CO representative.')
    end
  end
end
