require 'rails_helper'

feature 'Startup Edit' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }
  let(:co_founder) { create :user_with_password, confirmed_at: Time.now }
  let!(:tet_one_liner) { create :tet_one_liner }
  let!(:tet_new_product_deck) { create :tet_new_product_deck }
  let!(:tet_team_formed) { create :tet_team_formed }
  let!(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  let(:new_name) { Faker::Lorem.words(rand(3) + 1).join ' ' }
  let(:new_about) { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_ABOUT_CHARACTERS) }
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
      fill_in 'startup_name', with: new_name
      fill_in 'startup_about', with: new_about
      fill_in 'startup_presentation_link', with: new_deck
      click_on 'Update startup profile'

      startup.reload
      expect(startup.name).to eq(new_name)
      expect(startup.about).to eq(new_about)
      expect(startup.presentation_link).to eq(new_deck)
    end

    scenario 'Founder clears all required fields' do
      fill_in 'startup_name', with: ""
      fill_in 'startup_about', with: ""
      fill_in 'startup_presentation_link', with: ""
      click_on 'Update startup profile'

      expect(page).to have_text('Please review the problems below')
      expect(page.find('div.form-group.startup_name')[:class]).to include('has-error')
      expect(page.find('div.form-group.startup_about')[:class]).to include('has-error')
      expect(page.find('div.form-group.startup_presentation_link')[:class]).to include('has-error')
    end

    scenario 'Founder adds a valid co-founder to the startup' do
      fill_in 'cofounder_email', with: co_founder.email
      click_on 'Add as co-founder'

      expect(page.find('#current-founders-list')).to have_text(co_founder.email)
      co_founder.reload
      expect(co_founder.startup).to eq(startup)
      # TODO: Rewrite after including capybara-email gem ?
      # expect(ActionMailer::Base.deliveries.last.subject).to eq('SVApp: You have been added as startup cofounder!')
      # expect(ActionMailer::Base.deliveries.last.to).to eq([co_founder.email])
    end

    scenario 'Founder adds a random non-SV email as cofounder' do
      fill_in 'cofounder_email', with: Faker::Internet.email
      click_on 'Add as co-founder'

      expect(page.find('#current-founders-list')).not_to have_text(co_founder.email)
      # expect(page.find('.ui-pnotify-text')).to have_content('Please verify founder\'s registered email address')
    end

  end

end
