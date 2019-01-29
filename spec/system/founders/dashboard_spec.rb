require 'rails_helper'

feature 'Founder Dashboard' do
  include UserSpecHelper

  # The basics.
  let(:course) { create :course }
  let!(:startup) { create :startup, level: level_4 }
  let!(:founder) { create :founder, startup: startup }
  let(:faculty) { create :faculty }

  # Levels.
  let!(:level_0) { create :level, :zero, course: course }
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }
  let!(:level_4) { create :level, :four, course: course }
  let!(:level_5) { create :level, :five, course: course }
  let!(:locked_level_6) { create :level, :six, course: course, unlock_on: 1.month.from_now }

  # Tracks.
  let(:product_track) { create :track, name: 'Product', sort_index: 0 }
  let(:developer_track) { create :track, name: 'Developer', sort_index: 1 }

  # Target group we're interested in. Create milestone
  let!(:target_group_0) { create :target_group, level: level_0, milestone: true, track: product_track }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true, track: product_track }
  let!(:target_group_2) { create :target_group, level: level_2, milestone: true, track: product_track }
  let!(:target_group_3) { create :target_group, level: level_3, milestone: true, track: product_track }
  let!(:target_group_4) { create :target_group, level: level_4, milestone: true, track: product_track }
  let!(:target_group_5) { create :target_group, level: level_5, milestone: true, track: product_track }
  let!(:sessions_target_group) { create :target_group, name: 'Sessions' }

  # Individual targets of different types.
  let!(:pending_target) { create :target, target_group: target_group_4, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:completed_target_1) { create :target, target_group: target_group_2, role: Target::ROLE_TEAM }
  let!(:completed_target_2) { create :target, target_group: target_group_3, role: Target::ROLE_TEAM }
  let!(:completed_target_3) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:not_accepted_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:needs_improvement_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:target_with_prerequisites) { create :target, target_group: target_group_4, prerequisite_targets: [pending_target], role: Target::ROLE_TEAM }
  let!(:level_5_target) { create :target, target_group: target_group_5, role: Target::ROLE_TEAM }

  # Create sessions for the 'Sessions' target group.
  let!(:session_1) { create :target, target_group: sessions_target_group, session_at: 2.hours.from_now }
  let!(:session_2) { create :target, target_group: sessions_target_group, session_at: 3.days.ago }
  let!(:session_3) { create :target, target_group: sessions_target_group, session_at: 2.days.ago }

  let(:dashboard_toured) { true }

  before do
    # Extra target groups in tested level, in different tracks, and without track.
    create :target_group, level: level_4, track: product_track
    create :target_group, level: level_4, track: developer_track
    create :target_group, level: level_4

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
    scenario 'ex-founder attempts to visit dashboard' do
      sentence = Faker::Lorem.sentence
      stub_request(:get, "https://www.sv.co").to_return(status: 200, body: sentence)
      founder.update!(exited: true)
      sign_in_user founder.user, referer: student_dashboard_path
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

    # Check the number of founder avatars in the dashboard.
    # expect(page).to have_selector('.founder-dashboard__avatar-wrapper', count: startup.founders.count)

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

    # There is only one track in level 2, so the selector should be hidden.
    expect(page).not_to have_selector('.founder-dashboard-togglebar__toggle-btn')

    # Switch back to level 4...
    find('.filter-targets-dropdown__button').click
    find('.filter-targets-dropdown__menu-item', text: "Level 4: #{level_4.name}").click

    # There should be three tracks in Level 4.
    expect(page).to have_selector('.founder-dashboard-togglebar__toggle-btn', count: 3)

    find('.founder-dashboard-togglebar__toggle-btn', text: developer_track.name.upcase).click

    # Check whether there's correct number of target groups in the developer track.
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 1)

    find('.founder-dashboard-togglebar__toggle-btn', text: 'TARGETS').click

    # Check whether there's correct number of target groups in the special 'default' track.
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 1)

    # Ensure there is no Sessions Tab displayed
    expect(page).not_to have_selector('.founder-dashboard-togglebar__toggle-btn', text: 'SESSIONS')

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

  context "when the founders's course has a 'Sessions' target-group in it" do
    before do
      # Include the 'Sessions' target group in Level 1 and add all sessions to it.
      sessions_target_group.update!(level: level_1)
      sessions_target_group.targets << [session_1, session_2, session_3]
    end

    scenario 'founder visits the dashboard', js: true do
      sign_in_user founder.user, referer: student_dashboard_path

      # Ensure the Sessions Tab is visible
      expect(page).to have_selector('.founder-dashboard-togglebar__toggle-btn', text: 'SESSIONS')

      # Go to the sessions Tab
      find('.founder-dashboard-togglebar__toggle-btn', text: 'SESSIONS').click

      # Ensure all 3 sessions are displayed
      expect(page).to have_selector('.founder-dashboard-target-header__container', count: 3)
    end
  end

  context "when a founder's course has an archived target group in it" do
    let!(:target_group_4_archived) { create :target_group, :archived, level: level_4, milestone: true, track: product_track, description: Faker::Lorem.sentence }

    scenario 'archived target groups are not displayed', js: true do
      sign_in_user founder.user, referer: student_dashboard_path

      expect(page).not_to have_content(target_group_4_archived.description)
    end
  end
end
