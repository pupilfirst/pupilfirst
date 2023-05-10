require 'rails_helper'

feature 'Target Details Editor', js: true do
  include UserSpecHelper
  include NotificationHelper

  let(:github_configuration) do
    {
      access_token: 'access_token',
      organization_id: 'organization_id',
      default_team_id: 'default_team_id'
    }
  end
  let!(:school) { create :school, :current, configuration: { github: github_configuration } }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:course_author_user) { create :user, school: school }
  let!(:course_author) { create :course_author, course: course, user: course_author_user }

  let!(:level_1) { create :level, :one, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_1_l1) { create :target, target_group: target_group_1 }
  let(:action_config) { Faker::Lorem.sentence }

  scenario 'admin configures github actions for a target' do
    sign_in_user school_admin.user, referrer: action_school_target_path(id: target_1_l1.id)

    fill_in 'target_action_config', with: action_config
    click_button 'Update Action'

    expect(page).to have_text('Action updated successfully')
    dismiss_notification

    expect(target_1_l1.reload.action_config).to eq(action_config)
  end

  scenario 'author checks out github actions for a target' do
    sign_in_user course_author.user, referrer: action_school_target_path(id: target_1_l1.id)

    fill_in 'target_action_config', with: action_config
    click_button 'Update Action'

    expect(page).to have_text('Action updated successfully')
    dismiss_notification

    expect(target_1_l1.reload.action_config).to eq(action_config)
  end
end
