require 'rails_helper'

feature 'Startup Edit' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }
  let(:co_founder) { create :user_with_password, confirmed_at: Time.now }
  let!(:tet_one_liner) { create :tet_one_liner }
  let!(:tet_new_product_deck) { create :tet_new_product_deck }
  let!(:tet_team_formed) { create :tet_team_formed }
  let!(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  let(:new_product_name) { Faker::Lorem.words(rand(3) + 1).join ' ' }
  let(:new_product_description) { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
  let(:new_deck) { Faker::Internet.domain_name }

  before :each do
    # Add user as founder of startup.
    startup.founders << user

    # Log in the user.
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Sign in'
    visit edit_user_startup_path(user)

    # User should now be on his startup edit page.
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
      fill_in 'startup_product_description', with: ''
      fill_in 'startup_presentation_link', with: ""
      click_on 'Update startup profile'

      expect(page).to have_text('Please review the problems below')
      expect(page.find('div.form-group.startup_product_name')[:class]).to include('has-error')
      expect(page.find('div.form-group.startup_product_description')[:class]).to include('has-error')
      expect(page.find('div.form-group.startup_presentation_link')[:class]).to include('has-error')
    end

    scenario 'Founder adds a valid co-founder to the startup' do
      fill_in 'cofounder_email', with: co_founder.email
      click_on 'Add as co-founder'

      expect(page.find('.founders-table')).to have_text(co_founder.email)
      co_founder.reload
      expect(co_founder.startup).to eq(startup)
      open_email(co_founder.email)
      expect(current_email.subject).to eq('SVApp: You have been added as startup cofounder!')
    end

    scenario 'Non-admin founder views delete startup section' do
      expect(page).to have_text('Only the team leader can delete a startup\'s profile')
    end

    scenario 'Founder deletes his startup as startup_admin' do
      # change startup admin to this user
      startup.admin.update(startup_admin: false)
      user.update(startup_admin: true)
      startup.reload
      user.reload

      visit edit_user_startup_path(user)
      expect(page).to have_text('Deleting this startup is an irreversible action.')

      startup_id = startup.id
      fill_in 'startup_password', with: user.password
      click_on 'Confirm Startup Deletion'
      expect { Startup.find(startup_id) }.to raise_error ActiveRecord::RecordNotFound
      expect(user.startup).to be_nil
    end
  end
end
