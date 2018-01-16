require 'rails_helper'

feature 'Admission Screening' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.team_lead }
  let(:level_0) { create :level, :zero }
  let(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, link_to_complete: '/admissions/screening', target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition, target_group: level_0_targets }

  context 'Founder attempts to complete screening target' do
    scenario 'He gets redirected to typeform screening survey' do
      typeform_url = "http://example.com/typeform?user_id=#{founder.user.id}"

      sign_in_user founder.user, referer: admissions_screening_path
      expect(page.current_url).to eq(typeform_url)
    end
  end
end
