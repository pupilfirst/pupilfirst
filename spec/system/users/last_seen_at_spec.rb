require 'rails_helper'

feature "User's last seen at is updated periodically" do
  include UserSpecHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:student) { create :student }
  let(:user) { student.user }

  scenario 'user visits the dashboard page' do
    expect do
      sign_in_user(user, referrer: dashboard_path)
      expect(page).not_to have_text('Sign In')
    end.to(change { user.reload.last_seen_at })

    travel_to(10.minutes.from_now) do
      expect do
        visit dashboard_path
        expect(page).not_to have_text('Sign In')
      end.not_to(change { user.reload.last_seen_at })
    end

    travel_to(16.minutes.from_now) do
      expect do
        visit dashboard_path
        expect(page).not_to have_text('Sign In')
      end.to(change { user.reload.last_seen_at })
    end
  end
end
