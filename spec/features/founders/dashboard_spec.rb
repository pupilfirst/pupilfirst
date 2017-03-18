require 'rails_helper'

feature 'Founder Dashboard' do
  # The basics.
  let(:startup) { create :startup }
  let(:batch) { startup.batch }
  let(:founder) { startup.admin }

  # Program weeks.
  let!(:program_week_1) { create :program_week, batch: batch, number: 1 }
  let(:program_week_2) { create :program_week, batch: batch, number: 2 }
  let(:program_week_3) { create :program_week, batch: batch, number: 3 }

  # Target group we're interested in.
  let(:target_group_1) { create :target_group, program_week: program_week_1 }

  # Individual targets of different types.
  let!(:pending_target) { create :target, target_group: target_group_1, days_to_complete: 60 }
  let(:completed_target) { create :target, target_group: target_group_1 }
  let(:not_accepted_target) { create :target, target_group: target_group_1 }
  let(:needs_improvement_target) { create :target, target_group: target_group_1 }
  let!(:expired_target) { create :target, target_group: target_group_1, days_to_complete: 0 }
  let!(:target_with_prerequisites) { create :target, target_group: target_group_1, prerequisite_targets: [pending_target] }

  before do
    # Additional program weeks are displayed only if they have at least one target group in them.
    create(:target_group, program_week: program_week_2)
    create(:target_group, program_week: program_week_3)

    # Timeline events to take targets to specific states.
    create(:timeline_event, startup: startup, target: completed_target, verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED)
    create(:timeline_event, startup: startup, target: not_accepted_target, verified_status: TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED)
    create(:timeline_event, startup: startup, target: needs_improvement_target, verified_status: TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT)

    # Extra target groups in tested program week.
    3.times do
      create :target_group, program_week: program_week_1
    end

    # Sign in with Founder - set dashboard toured to true to avoid the tour.
    founder.update!(dashboard_toured: true)
    visit user_token_path(token: founder.user.login_token, referer: dashboard_founder_path)
  end

  context 'when founder has not visited dashboard before' do
    scenario 'founder visits dashboard', js: true, broken: true do
      # I expect to see the tour.
      founder.update!(dashboard_toured: false)
      visit dashboard_founder_path
      expect(page).to have_selector('.introjs-tooltipReferenceLayer', visible: false)
    end
  end

  context 'when founder has exited the programme' do
    scenario 'founder visits dashboard', js: true do
      founder.update!(exited: true)
      visit dashboard_founder_path
      expect(page).to have_text('not an active founder anymore')
    end
  end

  scenario 'founder visits dashboard', js: true, broken: true do
    # There should be no tour.
    expect(page).to_not have_selector('.introjs-tooltipReferenceLayer', visible: false)

    # Open the performance window.
    click_button 'Performance'
    expect(page).to have_selector('.startup-stats')
    within('.performance-overview.modal') do
      find('.modal-close').click
    end

    # Open the timeline builder modal.
    click_button 'Add Event'
    expect(page).to have_selector("div[data-react-class='TimelineBuilder']", visible: true)
    find('.timeline-builder__modal-close').click

    # Check whether there's correct number of program weeks.
    expect(page).to have_selector('.program-week-number', count: 2)

    # Scroll to bottom.
    page.execute_script('window.scrollBy(0, $(window).height())')

    # Week 2 should be loaded.
    expect(page).to have_content(program_week_2.name)

    # Scroll to bottom again.
    page.execute_script('window.scrollBy(0, $(window).height())')

    # Week 1 should be loaded.
    expect(page).to have_content(program_week_1.name)

    # All three weeks should be visible.
    expect(page).to have_selector('.program-week-number', count: 3)

    # Check whether there's correct number of target groups in the page.
    expect(page).to have_selector('.target-group', count: 6)

    # Check whether clicking each target gives the correct information.
    # 'Trigger' clicks on the element instead of actually clicking on it to avoid timing issues
    # with animation.
    find("#target-#{expired_target.id} .founder-dashboard-target-header__container").trigger('click')
    within("#target-#{expired_target.id}") do
      expect(page).to have_content('Target Expired').and have_content('You can still try submitting!').and have_button('Submit')
    end

    find("#target-#{pending_target.id} .founder-dashboard-target-header__container").trigger('click')
    within("#target-#{pending_target.id}") do
      expect(page).to have_content('Due date').and have_button('Submit')
    end

    find("#target-#{completed_target.id} .founder-dashboard-target-header__container").trigger('click')
    within("#target-#{completed_target.id}") do
      expect(page).to have_content('Target Completed').and have_button('Re-Submit')
    end

    find("#target-#{not_accepted_target.id} .founder-dashboard-target-header__container").trigger('click')
    within("#target-#{not_accepted_target.id}") do
      expect(page).to have_content('Submission Not Accepted').and have_button('Re-Submit')
    end

    find("#target-#{needs_improvement_target.id} .founder-dashboard-target-header__container").trigger('click')
    within("#target-#{needs_improvement_target.id}") do
      expect(page).to have_content('Submission Needs Improvement').and have_button('Re-Submit')
    end

    find("#target-#{target_with_prerequisites.id} .founder-dashboard-target-header__container").trigger('click')
    within("#target-#{target_with_prerequisites.id}") do
      expect(page).to have_content('Target Locked').and have_no_button
    end
  end
end
