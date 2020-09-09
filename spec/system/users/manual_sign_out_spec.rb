require 'rails_helper'

feature 'Manual User Sign Out', js: true do
  include ActiveSupport::Testing::TimeHelpers

  let(:startup) { create :startup }
  let(:user) { startup.founders.first.user }

  scenario 'active user session is interrupted by the setting of the flag' do
    # Log in the user.
    visit user_token_path(token: user.login_token, referrer: edit_user_path)

    expect(page).to have_content('profile')

    # Set the manual sign out field.
    user.update!(sign_out_at_next_request: true)

    travel_to 1.hour.from_now do
      visit edit_user_path

      # User should be signed out.
      expect(page).to have_text('Hello, welcome')

      # Log the user in again.
      user.regenerate_login_token

      visit user_token_path(token: user.login_token, referrer: edit_user_path)

      expect(page).to have_content('profile')
    end

    # After 1 week, he should be signed out again if the boolean is still set.
    travel_to 8.days.from_now do
      visit edit_user_path

      # User should be signed out.
      expect(page).to have_text('Hello, welcome')
    end
  end

  context 'when flag is set' do
    before do
      user.update!(sign_out_at_next_request: true)
    end

    scenario 'user signs in as usual' do
      visit user_token_path(token: user.login_token, referrer: edit_user_path)

      expect(page).to have_content('profile')

      travel_to 1.week.from_now do
        visit edit_user_path

        # User should be signed out.
        expect(page).to have_text('Hello, welcome')
      end
    end
  end
end
