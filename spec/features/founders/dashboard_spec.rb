require 'rails_helper'

feature 'Founder Dashboard' do
  include UserSpecHelper

  # The basics.
  let(:school) { create :school }
  let!(:startup) { create :startup, :subscription_active, level: level_4 }
  let!(:founder) { create :founder, startup: startup }

  # Levels.
  let!(:level_0) { create :level, :zero, school: school }
  let!(:level_1) { create :level, :one, school: school }
  let!(:level_2) { create :level, :two, school: school }
  let!(:level_3) { create :level, :three, school: school }
  let!(:level_4) { create :level, :four, school: school }
  let!(:level_5) { create :level, :five, school: school }

  # Tracks.
  let(:product_track) { create :track, name: 'Product', sort_index: 0 }
  let(:developer_track) { create :track, name: 'Developer', sort_index: 1 }

  # Target group we're interested in. Create milestone
  let!(:target_group_0) { create :target_group, level: level_0, milestone: true, track: product_track }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true, track: product_track }
  let!(:target_group_2) { create :target_group, level: level_2, milestone: true, track: product_track }
  let!(:target_group_3) { create :target_group, level: level_3, milestone: true, track: product_track }
  let!(:target_group_4) { create :target_group, level: level_4, milestone: true, track: product_track }

  # Individual targets of different types.
  let!(:pending_target) { create :target, target_group: target_group_4, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:completed_target_1) { create :target, target_group: target_group_2, role: Target::ROLE_TEAM }
  let!(:completed_target_2) { create :target, target_group: target_group_3, role: Target::ROLE_TEAM }
  let!(:completed_target_3) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:not_accepted_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:needs_improvement_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:target_with_prerequisites) { create :target, target_group: target_group_4, prerequisite_targets: [pending_target], role: Target::ROLE_TEAM }
  let!(:completed_fee_payment_target) { create :target, target_group: target_group_0, days_to_complete: 60, role: Target::ROLE_TEAM, key: Target::KEY_FEE_PAYMENT }

  # Create sessions for different levels.
  let!(:session_1) { create :target, target_group: target_group_4, session_at: 2.hours.from_now }
  let!(:session_2) { create :target, target_group: target_group_3, session_at: 3.days.ago }
  let!(:session_3) { create :target, target_group: target_group_2, session_at: 2.days.ago }
  let!(:session_4) { create :target, target_group: target_group_1, session_at: 1.day.ago }
  let!(:session_5) { create :target, target_group: target_group_1, session_at: 1.day.ago }

  let(:dashboard_toured) { true }

  before do
    # Extra target groups in tested level, in different tracks, and without track.
    create :target_group, level: level_4, track: product_track
    create :target_group, level: level_4, track: developer_track
    create :target_group, level: level_4

    # Timeline events to take targets to specific states.
    create(:timeline_event, startup: startup, target: completed_target_1, status: TimelineEvent::STATUS_VERIFIED)
    create(:timeline_event, startup: startup, target: completed_target_2, status: TimelineEvent::STATUS_VERIFIED)
    create(:timeline_event, startup: startup, target: completed_target_3, status: TimelineEvent::STATUS_VERIFIED)
    create(:timeline_event, startup: startup, target: not_accepted_target, status: TimelineEvent::STATUS_NOT_ACCEPTED)
    create(:timeline_event, startup: startup, target: needs_improvement_target, status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT)
    create(:timeline_event, startup: startup, target: completed_fee_payment_target, status: TimelineEvent::STATUS_VERIFIED)

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
      founder.update!(exited: true)
      sign_in_user founder.user, referer: student_dashboard_path
      expect(page).to have_text('not an active student anymore')
    end
  end

  scenario 'founder visits dashboard', js: true do
    sign_in_user founder.user, referer: student_dashboard_path

    # There should be no tour.
    expect(page).to_not have_selector('.introjs-tooltipReferenceLayer', visible: false)

    # Check the number of founder avatars in the dashboard.
    expect(page).to have_selector('.founder-dashboard__avatar-wrapper', count: startup.founders.count)

    # Check the product name displayed in the dashboard.
    expect(page).to have_selector('.founder-dashboard-header__product-title', text: startup.product_name)

    # Close the PNotify message to ensure no overlap with other elements under test
    find('.ui-pnotify').click

    # Founder can manually start a dashboard tour.
    find('.founder-dashboard-actionbar__show-more-menu-dots').click
    find('a[id=filter-targets-dropdown__tour-button]').click

    expect(page).to have_selector('.introjs-tooltipReferenceLayer', visible: false)

    # End the tour. We're not interested in its contents.
    within('.introjs-tooltip') do
      find('.introjs-skipbutton').click
    end

    find('.founder-dashboard-actionbar__box').click

    # Open the timeline builder modal.
    click_button 'Add Event'
    expect(page).to have_selector('.timeline-builder__popup-body', visible: true)
    find('.timeline-builder__modal-close').click

    # Check whether there's correct number of target groups in the page.
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 2)

    # Check whether there's one Milestone Target Group
    expect(page).to have_selector('.founder-dashboard-target-group__milestone-label', count: 1)

    # Check the level filters in the action bar.
    find('.filter-targets-dropdown__button').click
    within('.filter-targets-dropdown__menu') do
      expect(page).to have_selector('.filter-targets-dropdown__menu-item', count: 5)
      expect(page).to have_selector('.fa-lock', count: 1)
      expect(page).to have_selector('.fa-unlock', count: 4)
    end

    # Select another level and check if the correct data is displayed.
    find('.filter-targets-dropdown__menu-item', text: "Level 2: #{level_2.name}").click
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 1)
    expect(page).to have_selector('.founder-dashboard-target-header__container', count: 2)

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

    find('.founder-dashboard-togglebar__toggle-btn', text: level_4.name.upcase).click

    # Check whether there's correct number of target groups in the special 'default' track.
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 1)
  end
end
