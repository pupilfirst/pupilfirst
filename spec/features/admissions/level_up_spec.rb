require 'rails_helper'

feature 'Admission Level up' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.team_lead }

  let(:level_0) { create :level, :zero }
  let(:l0_target_group) { create :target_group, level: level_0, milestone: true }
  let!(:screening_target) { create :target, :admissions_screening, target_group: l0_target_group }
  let!(:cofounder_target) { create :target, :admissions_cofounder_addition, target_group: l0_target_group }
  let!(:payment_target) { create :target, :admissions_fee_payment, target_group: l0_target_group }

  context 'before completing targets' do
    scenario 'founder cannot level up', js: true do
      sign_in_user founder.user, referer: dashboard_founder_path
      expect(page).not_to have_content('You have successfully completed the first step in your startup journey')
    end
  end

  context 'after completing targets' do
    let(:level_1) { create :level, :one }
    let(:l1_target_group) { create :target_group, level: level_1, milestone: true }

    before do
      # Joined timeline event type is required to be able to create a timeline event to mark occasion.
      create :tet_joined

      # At least one target should be present in level 1.
      create :target, target_group: l1_target_group

      # Complete screening.
      complete_target founder, screening_target

      # Complete cofounder addition target.
      create :founder, startup: startup
      complete_target founder, cofounder_target

      # Complete fee_payment target.
      create :payment, :paid, startup: startup
      complete_target founder, payment_target
    end

    scenario 'founder can level up', js: true do
      sign_in_user founder.user, referer: dashboard_founder_path

      expect(page).to have_content('You have successfully completed the first step in your startup journey')
      click_button 'Level Up'

      expect(page).to have_content(l1_target_group.name)
    end
  end
end
