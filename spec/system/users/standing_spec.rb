require "rails_helper"

feature "User standing", js: true do
  include UserSpecHelper

  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:user) { create :user, school: school }
  let!(:standing_1) { create :standing, school: school, default: true }
  let!(:standing_2) { create :standing, school: school }
  let!(:standing_3) { create :standing, school: school }

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  scenario "user cannot see standings if standing is disabled" do
    sign_in_user user, referrer: standing_user_path

    expect(page).to have_text(user.name)

    expect(page).to have_text(user.full_title)

    expect(page).to have_text("Standing is not enabled for this school")
  end

  context "when school standing is enabled" do
    before { school.update!(configuration: { enable_standing: true }) }
    scenario "user visits standing page with no standing logs" do
      sign_in_user user, referrer: standing_user_path

      expect(page).to have_current_path(standing_user_path)

      expect(page).to have_text(user.name)

      expect(page).to have_text(user.full_title)

      expect(page).to have_text(standing_1.name)

      expect(page).to have_text("There are no entries in the log")

      expect(page).to have_link("View Code of Conduct")

      click_link "View Code of Conduct"

      expect(page).to have_current_path(
        agreement_path(agreement_type: "code-of-conduct")
      )
    end

    context "there are standing logs created" do
      let!(:standing_log_1) do
        create :user_standing,
               user: user,
               standing: standing_1,
               creator: school_admin.user
      end
      let!(:standing_log_2) do
        create :user_standing,
               user: user,
               standing: standing_2,
               creator: school_admin.user
      end
      let!(:standing_log_3) do
        create :user_standing,
               user: user,
               standing: standing_3,
               creator: school_admin.user
      end

      scenario "user visits standing page" do
        sign_in_user user, referrer: standing_user_path

        expect(page).to have_current_path(standing_user_path)

        expect(page).to have_text(user.name)

        expect(page).to have_text(user.full_title)

        within("div[aria-label='Current standing card']") do
          expect(page).to have_text(standing_3.name)
        end

        within("div[aria-label='Current standing shield']") do
          svg_content = find("svg")
          expect(svg_content[:fill]).to include(standing_3.color)
        end

        expect(page).to have_text(standing_1.name)
        expect(page).to have_text(
          standing_log_1.created_at.strftime("%B %-d, %Y")
        )
        expect(page).to have_text(
          standing_log_1.created_at.strftime("%-l:%M %p")
        )
        expect(page).to have_text(standing_log_1.reason)

        expect(page).to have_text(standing_2.name)
        expect(page).to have_text(
          standing_log_2.created_at.strftime("%B %-d, %Y")
        )
        expect(page).to have_text(
          standing_log_2.created_at.strftime("%-l:%M %p")
        )
        expect(page).to have_text(standing_log_2.reason)

        expect(page).to have_text(standing_3.name)
        expect(page).to have_text(
          standing_log_3.created_at.strftime("%B %-d, %Y")
        )
        expect(page).to have_text(
          standing_log_3.created_at.strftime("%-l:%M %p")
        )
        expect(page).to have_text(standing_log_3.reason)

        expect(page).to have_link("View Code of Conduct")

        click_link "View Code of Conduct"

        expect(page).to have_current_path(
          agreement_path(agreement_type: "code-of-conduct")
        )
      end
    end
  end
end
