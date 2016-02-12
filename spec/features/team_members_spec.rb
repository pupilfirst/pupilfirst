require 'rails_helper'

feature 'Team members spec' do
  let(:user) { create :founder_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  before do
    # Add user as founder of startup.
    startup.founders << user

    # Login with user.
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Sign in'
  end

  context 'User has verified timeline event for founder target' do
    scenario 'User edits Startup profile' do
      visit edit_user_startup_url

      expect(page).to have_text('There aren\'t any (non-founder) team members associated with your startup.')
    end

    scenario 'User adds a team member' do
      visit edit_user_startup_url
      click_on 'Add new team member'

      # On the 'new' page.
      fill_in 'Name', with: 'Jack Sparrow'
      check 'Product'
      check 'Engineering'
      fill_in 'Email address', with: 'jack.sparrow@sv.co'
      page.attach_file 'team_member_avatar', File.expand_path(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'jack_sparrow.png'))

      click_on 'List new team member'

      expect(page).to have_text 'Jack Sparrow'
      expect(page).to have_text 'jack.sparrow@sv.co'
      expect(page).to have_text 'Product, Engineering'
    end

    scenario 'User attempts to add team member without necessary fields' do
      visit edit_user_startup_url
      click_on 'Add new team member'
      click_on 'List new team member'

      expect(page.find('.team_member_name')[:class]).to include('has-error')
      expect(page.find('.team_member_roles')[:class]).to include('has-error')
      expect(page).to have_text 'can\'t be blank'
      expect(page).to have_text 'pick at least one'
    end

    scenario 'User attempts to choose more than two roles' do
      visit edit_user_startup_url
      click_on 'Add new team member'

      check 'Product'
      check 'Engineering'
      check 'Governance'
      click_on 'List new team member'

      expect(page.find('.team_member_roles')[:class]).to include('has-error')
      expect(page).to have_text 'pick no more than two'
    end

    context 'There is an existing team member' do
      let!(:team_member) { create :team_member, startup: startup }

      scenario 'User deletes existing team member' do
        visit edit_user_startup_url

        within '.team-member-table' do
          click_on 'Remove'
        end

        expect(page).to have_text('There aren\'t any (non-founder) team members associated with your startup.')
      end
    end
  end
end
