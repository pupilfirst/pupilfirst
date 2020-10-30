require 'rails_helper'

feature 'User signing in by supplying email address', js: true do
  let!(:school) { create :school, :current }

  context 'when a user exists' do
    let(:user) { create :user }

    context "when the user hasn't signed in" do
      scenario 'user is redirected to keycloak login form' do
        visit new_user_session_path
        expect(page).to have_current_path(oauth_path(:keycloakopenid))
      end
    end
  end
end
