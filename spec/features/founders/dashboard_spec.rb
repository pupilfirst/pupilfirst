require 'rails_helper'

feature 'Founder Dashboard' do
  include UserSpecHelper

  # The basics.
  let!(:startup) { create :startup, :subscription_active, level: level_4 }
  let!(:founder) { create :founder, startup: startup }

  # Levels.
  let!(:level_0) { create :level, :zero }
  let!(:level_1) { create :level, :one }
  let!(:level_2) { create :level, :two }
  let!(:level_3) { create :level, :three }
  let!(:level_4) { create :level, :four }
  let!(:level_5) { create :level, :five }

  # Target group we're interested in. Create milestone
  let!(:target_group_0) { create :target_group, level: level_0, milestone: true }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true }
  let!(:target_group_2) { create :target_group, level: level_2, milestone: true }
  let!(:target_group_3) { create :target_group, level: level_3, milestone: true }
  let!(:target_group_4) { create :target_group, level: level_4, milestone: true }

  # Individual targets of different types.
  let!(:pending_target) { create :target, target_group: target_group_4, days_to_complete: 60, role: Target::ROLE_TEAM }
  let!(:completed_target_1) { create :target, target_group: target_group_2, role: Target::ROLE_TEAM }
  let!(:completed_target_2) { create :target, target_group: target_group_3, role: Target::ROLE_TEAM }
  let!(:completed_target_3) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:not_accepted_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:needs_improvement_target) { create :target, target_group: target_group_4, role: Target::ROLE_TEAM }
  let!(:target_with_prerequisites) { create :target, target_group: target_group_4, prerequisite_targets: [pending_target], role: Target::ROLE_TEAM }
  let!(:completed_fee_payment_target) { create :target, target_group: target_group_0, days_to_complete: 60, role: Target::ROLE_TEAM, key: Target::KEY_ADMISSIONS_FEE_PAYMENT }

  # Create chores for different target groups.
  let!(:chore_1) { create :target, chore: true, target_group: target_group_4 }
  let!(:chore_2) { create :target, chore: true, target_group: target_group_3 }
  let!(:chore_3) { create :target, chore: true, target_group: target_group_2 }
  let!(:chore_4) { create :target, chore: true, target_group: target_group_1 }

  # Create sessions for different levels.
  let!(:session_1) { create :target, target_group: nil, level: level_4, session_at: 2.hours.from_now }
  let!(:session_2) { create :target, target_group: nil, level: level_3, session_at: 3.days.ago }
  let!(:session_3) { create :target, target_group: nil, level: level_2, session_at: 2.days.ago }
  let!(:session_4) { create :target, target_group: nil, level: level_1, session_at: 1.day.ago }
  let!(:session_5) { create :target, target_group: nil, level: level_1, session_at: 1.day.ago }

  let(:dashboard_toured) { true }

  # Create timeline_event_type of type 'end_iteration' for startup restart
  let!(:tet_end_iteration) { create :timeline_event_type, key: TimelineEventType::TYPE_END_ITERATION }

  before do
    # Timeline events to take targets to specific states.
    create(:timeline_event, startup: startup, target: completed_target_1, status: TimelineEvent::STATUS_VERIFIED)
    create(:timeline_event, startup: startup, target: completed_target_2, status: TimelineEvent::STATUS_VERIFIED)
    create(:timeline_event, startup: startup, target: completed_target_3, status: TimelineEvent::STATUS_VERIFIED)
    create(:timeline_event, startup: startup, target: not_accepted_target, status: TimelineEvent::STATUS_NOT_ACCEPTED)
    create(:timeline_event, startup: startup, target: needs_improvement_target, status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT)
    create(:timeline_event, startup: startup, target: completed_fee_payment_target, status: TimelineEvent::STATUS_VERIFIED)

    # Extra target groups in tested level.
    3.times do
      create :target_group, level: level_4
    end

    # Sign in with Founder - set dashboard toured to true to avoid the tour.
    founder.update!(dashboard_toured: dashboard_toured)
  end

  context 'when founder has not visited dashboard before' do
    let(:dashboard_toured) { false }

    scenario 'founder sees tour of dashboard', js: true do
      # I expect to see the tour.
      sign_in_user founder.user, referer: dashboard_founder_path
      expect(page).to have_selector('.introjs-tooltipReferenceLayer', visible: false)
    end
  end

  context 'when founder has exited the programme' do
    scenario 'ex-founder attempts to visit dashboard', js: true do
      founder.update!(exited: true)
      sign_in_user founder.user, referer: dashboard_founder_path
      expect(page).to have_text('not an active founder anymore')
    end
  end

  scenario 'founder visits dashboard', js: true do
    sign_in_user founder.user, referer: dashboard_founder_path

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
    within('.introjs-tooltip') do
      find('.introjs-skipbutton').click
    end
    find('.founder-dashboard-actionbar__box').click

    # Open the performance window.
    find('.founder-dashboard-actionbar__show-more-menu-dots').click
    find('a[data-target="#performance-overview-modal"]').click
    expect(page).to have_selector('.startup-stats')
    within('.performance-overview.modal') do
      find('.modal-close').click
    end

    # Open the timeline builder modal.
    click_button 'Add Event'
    expect(page).to have_selector('.timeline-builder__popup-body', visible: true)
    find('.timeline-builder__modal-close').click

    # Check the level filters in the action bar.
    find('.filter-targets-dropdown__button').click
    within('.filter-targets-dropdown__menu') do
      expect(page).to have_selector('.filter-targets-dropdown__menu-item', count: 5)
      expect(page).to have_selector('.fa-lock', count: 1)
      expect(page).to have_selector('.fa-unlock', count: 4)
    end

    ####
    # Check whether the data in the targets tab is correct.
    ####

    # Check whether there's correct number of target groups in the page.
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 4)

    # Check whether there's one Milestone Target Group
    expect(page).to have_selector('.founder-dashboard-target-group__milestone-label', count: 1)

    # Select another level and check if the correct data is displayed.
    find('.filter-targets-dropdown__menu-item', text: "Level 2: #{level_2.name}").click
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 1)
    expect(page).to have_selector('.founder-dashboard-target-header__container', count: 2)

    ####
    # Check whether the data in Sessions tab is correct.
    ####

    find('.founder-dashboard-togglebar__toggle-btn', text: 'SESSIONS').click
    within('.founder-dashboard-togglebar__toggle-btn', text: 'SESSIONS') do
      expect(page).to have_selector('.founder-dashboard-togglebar__toggle-btn-notify', text: 5)
    end
    expect(page).to have_selector('.founder-dashboard-sessions__tag-select-container')

    # Check upcoming sessions and past sessions.
    expect(page).to have_selector('.founder-dashboard-target-group__box', count: 2)

    within('.founder-dashboard-target-group__box', text: 'Upcoming Sessions') do
      expect(page).to have_selector('.founder-dashboard-target__container', count: 1)
    end

    within('.founder-dashboard-target-group__box', text: 'Past Sessions') do
      expect(page).to have_selector('.founder-dashboard-target__container', count: 4)
    end

    ####
    # Check the startup restart functionality
    ####

    find('.founder-dashboard-actionbar__show-more-menu-dots').click
    find('a[data-target="#startup-restart-form"]').click
    expect(page).to have_selector('#startup-restart-form')

    within('#startup-restart-form') do
      expect(page).to have_text('Pivot your startup journey!')
      select level_2.name.to_s, from: 'founders_startup_restart_level_id'
      fill_in 'founders_startup_restart_reason', with: Faker::Lorem.sentence
      click_on 'Request For a Pivot'
    end

    visit dashboard_founder_path

    # Check whether end_iteration timeline event is created
    te = TimelineEvent.last
    expect(te.timeline_event_type).to eq(tet_end_iteration)

    # Check whether startup requested level for restart is set.
    expect(startup.reload.requested_restart_level).to eq(level_2)
  end
end
