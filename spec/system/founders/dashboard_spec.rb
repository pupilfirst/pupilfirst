require 'rails_helper'

feature 'Founder Dashboard' do
  include UserSpecHelper

  # The basics.
  let(:course) { create :course }
  let!(:startup) { create :startup, level: level_4 }
  let!(:founder) { create :founder, startup: startup }
  let(:faculty) { create :faculty }

  # Levels.
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }
  let!(:level_4) { create :level, :four, course: course }
  let!(:level_5) { create :level, :five, course: course }
  let!(:locked_level_6) { create :level, :six, course: course, unlock_on: 1.month.from_now }

  # Target group we're interested in. Create milestone
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true }
  let!(:target_group_2) { create :target_group, level: level_2, milestone: true }
  let!(:target_group_3) { create :target_group, level: level_3, milestone: true }
  let!(:target_group_4) { create :target_group, level: level_4, milestone: true }
  let!(:target_group_5) { create :target_group, level: level_5, milestone: true }
  let!(:target_group_6) { create :target_group, level: level_4 }

  # Individual targets of different types.
  let!(:pending_target) { create :target, target_group: target_group_4, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:completed_target_1) { create :target, target_group: target_group_2, role: Target::ROLE_TEAM }
  let!(:completed_target_2) { create :target, target_group: target_group_3, role: Target::ROLE_TEAM }
  let!(:completed_target_3) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:not_accepted_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:needs_improvement_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:target_with_prerequisites) { create :target, target_group: target_group_4, prerequisite_targets: [pending_target], role: Target::ROLE_TEAM }
  let!(:level_5_target) { create :target, target_group: target_group_5, role: Target::ROLE_TEAM }

  let(:dashboard_toured) { true }

  before do
    # Timeline events to take targets to specific states.
    create(:timeline_event, founders: startup.founders, target: completed_target_1, passed_at: 1.day.ago)
    create(:timeline_event, founders: startup.founders, target: completed_target_2, passed_at: 1.day.ago)
    create(:timeline_event, founders: startup.founders, target: completed_target_3, passed_at: 1.day.ago)
    create(:timeline_event, founders: startup.founders, target: not_accepted_target, evaluator: faculty)
    create(:timeline_event, founders: startup.founders, target: needs_improvement_target, passed_at: 1.day.ago)

    # Sign in with Founder - set dashboard toured to true to avoid the tour.
    founder.update!(dashboard_toured: dashboard_toured)
  end

  context 'when founder has not visited dashboard before' do
    let(:dashboard_toured) { false }

    scenario 'founder sees tour of dashboard', js: true do
      # I expect to see the tour.
      sign_in_user founder.user, referer: student_dashboard_path
      expect(page).to have_selector('.introjs-tooltipReferenceLayer', visible: false)
    end
  end

  context 'when founder has exited the programme' do
    scenario 'ex-founder attempts to visit dashboard', js: true do
      founder.update!(exited: true)
      sign_in_user founder.user, referer: student_dashboard_path
      expect(current_url).to eq('https://www.sv.co/')
    end
  end

  context 'when the course the founder belongs has ended' do
    before do
      course.update!(ends_at: 2.days.ago)
    end
    scenario 'founder visits the dashboard', js: true do
      sign_in_user founder.user, referer: student_dashboard_path
      expect(page).to have_selector('.founder-dashboard-notification__box')
      within('.founder-dashboard-notification__box') do
        expect(page).to have_text('The course has ended')
      end
    end
  end

  scenario 'founder visits dashboard', js: true do
    sign_in_user founder.user, referer: student_dashboard_path

    # There should be no tour.
    expect(page).to_not have_selector('.introjs-tooltipReferenceLayer', visible: false)

    # Check the product name displayed in the dashboard.
    expect(page).to have_selector('.founder-dashboard-header__product-title', text: startup.product_name)

    # Founder can manually start a dashboard tour.
    find('.founder-dashboard-actionbar__show-more-menu-dots').click
    find('a[id=filter-targets-dropdown__tour-button]').click

    expect(page).to have_selector('.introjs-tooltipReferenceLayer', visible: false)

    # End the tour. We're not interested in its contents.
    within('.introjs-tooltip') do
      find('.introjs-skipbutton').click
    end

    find('.founder-dashboard-actionbar__box').click

    # Check whether there's correct number of target groups in the page.
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 2)

    # Check whether there's one Milestone Target Group
    expect(page).to have_selector('.founder-dashboard-target-group__milestone-label', count: 1)

    # Check the level filters in the action bar.
    find('.filter-targets-dropdown__button').click
    within('.filter-targets-dropdown__menu') do
      expect(page).to have_selector('.filter-targets-dropdown__menu-item', count: 6)
      expect(page).to have_selector('.fa-check', count: 3)
      expect(page).to have_selector('.fa-map-marker', count: 1)
      expect(page).to have_selector('.fa-eye', count: 1)
      expect(page).to have_selector('.fa-lock', count: 1)
    end

    # Select another level and check if the correct data is displayed.
    find('.filter-targets-dropdown__menu-item', text: "Level 2: #{level_2.name}").click
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 1)
    expect(page).to have_selector('.founder-dashboard-target-header__container', count: 1)

    # There is no level 0, so the toggle bar should be hidden.
    expect(page).not_to have_selector('.founder-dashboard-togglebar__toggle-btn')

    # Visit the read-only level 5
    find('.filter-targets-dropdown__button').click
    find('.filter-targets-dropdown__menu-item', text: "Level 5: #{level_5.name}").click
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 1)
    expect(page).to have_selector('.founder-dashboard-target-header__container', count: 1)
    expect(page).to have_selector('.founder-dashboard-target-header__status-badge-block', text: 'Preview', count: 1)

    # Ensure level 6 is displayed locked
    find('.filter-targets-dropdown__button').click
    expect(page).to have_selector('.filter-targets-dropdown__menu-item--disabled', text: "Level 6: #{locked_level_6.name}")
  end

  context "when the founders's course has a Level 0 in it" do
    let(:level_0) { create :level, :zero, course: course }
    let(:target_group_1) { create :target_group, level: level_0 }
    let!(:level_0_target) { create :target, target_group: target_group_1, role: Target::ROLE_TEAM }

    scenario 'founder visits the dashboard', js: true do
      sign_in_user founder.user, referer: student_dashboard_path
      # Ensure the correct ToggleBar is visible
      expect(page).to have_selector('.founder-dashboard-togglebar__toggle-btn', text: level_4.name.upcase)
      expect(page).to have_selector('.founder-dashboard-togglebar__toggle-btn', text: level_0.name.upcase)

      # Go to the level 0 Tab
      find('.founder-dashboard-togglebar__toggle-btn', text: level_0.name.upcase).click

      # Ensure only the single level 0 displayed
      expect(page).to have_selector('.founder-dashboard-target-header__container', count: 1)
    end
  end

  context "when a founder's course has an archived target group in it" do
    let!(:target_group_4_archived) { create :target_group, :archived, level: level_4, milestone: true, description: Faker::Lorem.sentence }

    scenario 'archived target groups are not displayed', js: true do
      sign_in_user founder.user, referer: student_dashboard_path

      expect(page).not_to have_content(target_group_4_archived.description)
    end
  end
end
