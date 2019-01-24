require 'rails_helper'

feature 'Admission Level up', broken: true do
  include UserSpecHelper
  include FounderSpecHelper
  let(:course) { create :course }
  let(:level_0) { create :level, :zero, course: course }
  let(:startup) { create :startup, level: level_0 }
  let(:founder) { startup.founders.first }

  let(:l0_target_group) { create :target_group, level: level_0, milestone: true }
  let!(:screening_target) { create :target, :admissions_screening, target_group: l0_target_group }
  let!(:cofounder_target) { create :target, :admissions_cofounder_addition, target_group: l0_target_group }
  let!(:payment_target) { create :target, :admissions_fee_payment, target_group: l0_target_group }

  context 'before completing targets' do
    scenario 'founder cannot level up', js: true do
      sign_in_user founder.user, referer: student_dashboard_path
      expect(page).not_to have_content('You have successfully completed the first step in your journey with SV.CO')
    end
  end

  context 'after completing targets' do
    let(:level_1) { create :level, :one, course: course }
    let(:l1_target_group) { create :target_group, level: level_1, milestone: true }

    before do
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
      sign_in_user founder.user, referer: student_dashboard_path

      expect(page).to have_content('You have successfully completed the first step in your journey with SV.CO')
      click_button 'Level Up'

      expect(page).to have_content(l1_target_group.name)
    end
  end
end
