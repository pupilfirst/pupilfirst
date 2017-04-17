require 'rails_helper'

feature 'Editing founders during admission' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.admin }
  let(:level_0) { create :level, :zero }
  let!(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition, target_group: level_0_targets }

  context "when founder hasn't completed prerequisites" do
    scenario 'founder is blocked from editing founders' do
      sign_in_user(founder.user, referer: admissions_founders_path)

      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  context 'when founder has compeleted prerequisites' do
    before do
      complete_target founder, screening_target
      complete_target founder, fee_payment_target
    end

    scenario 'founder adds a cofounder', js: true do
      sign_in_user(founder.user, referer: admissions_founders_path)

      expect(page).to have_content('You are the team lead.')
      expect(page).to have_selector('.founders-form__founder-content-box', count: 1)

      page.find('.founders-form__add-founder-button').click

      expect(page).to have_selector('.founders-form__founder-content-box', count: 2)

      name = Faker::Name.name
      email = Faker::Internet.email(name)
      college_name = Faker::Lorem.words(3).join(' ')
      mobile = '8976543210'

      within all('.founders-form__founder-content-box').last do
        fill_in 'Name', with: name
        fill_in 'Email address', with: email
        fill_in 'Mobile phone number', with: mobile
        select "My college isn't listed", from: 'College'
        fill_in 'Name of your college', with: college_name
      end

      click_button 'Save founders'

      expect(page).to have_content('Details of founders have been saved!')

      expect(startup.founders.count).to eq(1)
      expect(startup.invited_founders.count).to eq(1)

      invited_founder = startup.invited_founders.first

      expect(invited_founder.name).to eq(name)
      expect(invited_founder.email).to eq(email)
      expect(invited_founder.phone).to eq(mobile)
      expect(invited_founder.college_text).to eq(college_name)
    end
  end
end
