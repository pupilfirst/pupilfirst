require 'rails_helper'

feature 'Manual User Sign Out' do
  include ActiveSupport::Testing::TimeHelpers

  let(:startup) { create :startup, :subscription_active }
  let(:user) { startup.team_lead.user }

  scenario 'active user session is interrupted by the setting of the flag' do
    # Log in the user.
    visit user_token_url(token: user.login_token, referer: edit_startup_path)

    expect(page).to have_content('Edit your startup profile')

    # Set the manual sign out field.
    user.update!(sign_out_at_next_request: true)

    travel_to 1.hour.from_now do
      visit edit_startup_path

      # User should be signed out.
      expect(page).to have_content('learn to build tech-products, the startup way')

      # Log the user in again.
      user.regenerate_login_token

      visit user_token_url(token: user.login_token, referer: edit_startup_path)

      expect(page).to have_content('Edit your startup profile')
    end

    # After 1 week, he should be signed out again if the boolean is still set.
    travel_to 8.days.from_now do
      visit edit_startup_path

      # User should be signed out.
      expect(page).to have_content('learn to build tech-products, the startup way')
    end
  end

  context 'when flag is set' do
    before do
      user.update!(sign_out_at_next_request: true)
    end

    scenario 'user signs in as usual' do
      visit user_token_url(token: user.login_token, referer: edit_startup_path)

      expect(page).to have_content('Edit your startup profile')

      travel_to 1.week.from_now do
        visit edit_startup_path

        # User should be signed out.
        expect(page).to have_content('learn to build tech-products, the startup way')
      end
    end
  end
end
