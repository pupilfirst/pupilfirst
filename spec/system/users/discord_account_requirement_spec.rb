require "rails_helper"

feature "Discord account requirement", js: true do
  include UserSpecHelper
  include ConfigHelper

  let(:student) { create :student }
  let(:user) { student.user }
  let(:course) { student.course }

  around do |example|
    with_secret(sso: { discord: { key: "DISCORD_KEY" } }) { example.run }
  end

  before do
    course.update!(discord_account_required: true)

    course.school.update(
      configuration: {
        discord: {
          server_id: "DISCORD_SERVER_ID",
          bot_token: "DISCORD_BOT_TOKEN"
        }
      }
    )
  end

  scenario "user is prompted to connect a Discord account; afterwards is shown link to course" do
    sign_in_user(
      user,
      referrer:
        discord_account_required_user_path(course_requiring_discord: course.id)
    )

    expect(page).to have_text("Let's link your Discord account first")

    # Let's pretend that the user has connected their Discord account, and will now return
    # to the school website.
    user.update!(discord_user_id: "DISCORD_USER_ID")

    # They'll end up at the edit path this time, so let's make sure that they're redirected
    # to the discord account requirement page again.
    visit(edit_user_path)

    expect(page).to have_link(
      "Begin course",
      href: curriculum_course_path(course)
    )

    # Trying to visit the Discord account required page again, after connecting Discord
    # account should ask the student to return to their dashboard.
    visit(discord_account_required_user_path)

    expect(page).to have_link(
      "Return to dashboard",
      href: dashboard_path
    )
  end
end
