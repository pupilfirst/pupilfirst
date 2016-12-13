require 'rails_helper'

feature 'Admin Target Modifications' do
  # create an admin user
  let(:admin_user) { create :admin_user, admin_type: 'superadmin' }

  # admin pages always require a batch
  # TODO: Probably remove this dependency. Culprit is the selected_batch_ids definition in active_admin_helper
  let!(:batch) { create :batch }

  before do
    # stub requests to intercom
    ActiveAdmin::DashboardPresenter::INTERCOM_METHODS.each do |method|
      allow_any_instance_of(IntercomClient).to receive(method).and_return(0)
    end

    # login as admin
    visit new_admin_user_session_path
    fill_in 'admin_user_email', with: admin_user.email
    fill_in 'admin_user_password', with: admin_user.password
    click_on 'Login'
  end

  context 'when a target already has a batch through program week' do
    let(:target) { create :target, :with_program_week, batch: batch }
    let!(:batch_2) { create :batch }

    scenario 'admin modifies batch to a different one' do
      # visit the edit page of the target
      visit edit_admin_target_path(target.id)
      expect(page).to have_text('Edit Target')

      # change the targets batch
      select batch_2.name, from: 'target_batch_id'
      click_on 'Update Target'

      # it should raise error and re-display the form
      expect(page).to have_text('Edit Target')
      expect(page).to have_text("Batch Does not match Program week's batch")
    end
  end
end
