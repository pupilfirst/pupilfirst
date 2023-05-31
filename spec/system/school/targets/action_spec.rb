require "rails_helper"

feature "Target Details Editor", js: true do
  include UserSpecHelper
  include NotificationHelper

  let(:github_configuration) do
    {
      access_token: "access_token",
      organization_id: "organization_id",
      default_team_id: "default_team_id",
    }
  end
  let!(:school) do
    create :school, :current, configuration: { github: github_configuration }
  end
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:course_author_user) { create :user, school: school }
  let!(:course_author) do
    create :course_author, course: course, user: course_author_user
  end

  let!(:level_1) { create :level, :one, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_1_l1) { create :target, target_group: target_group_1 }
  let(:action_config) { Faker::Lorem.sentence }
  let!(:student) { create :founder }

  scenario "admin configures github actions for a target" do
    sign_in_user school_admin.user,
                 referrer: action_school_target_path(id: target_1_l1.id)

    fill_in "target_action_config", with: action_config
    click_button "Update Action"

    expect(page).to have_text("Action updated successfully")
    dismiss_notification

    expect(target_1_l1.reload.action_config).to eq(action_config)
  end

  scenario "admin configures invalid yaml for a target" do
    sign_in_user school_admin.user,
                 referrer: action_school_target_path(id: target_1_l1.id)

    fill_in "target_action_config", with: "key: 'invalid,value"
    click_button "Update Action"

    expect(page).to have_text(
      "Action could not be updated, please check the YAML syntax",
    )
    dismiss_notification

    expect(target_1_l1.reload.action_config).to be_nil
  end

  scenario "user who is not logged in gets redirected to sign in page" do
    visit action_school_target_path(id: target_1_l1.id)
    expect(page).to have_text("Please sign in to continue.")
  end

  scenario "student cannot access this page" do
    sign_in_user student.user,
                 referrer: action_school_target_path(id: target_1_l1.id)

    expect(page).to have_text("The page you were looking for doesn't exist!")
  end
end
