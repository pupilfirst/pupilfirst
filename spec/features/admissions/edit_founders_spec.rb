require 'rails_helper'

feature 'Edit founders' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.admin }
  let(:level_0) { create :level, :zero }
  let!(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition, target_group: level_0_targets }

  context "when founder hasn't completed the screening prerequisites" do
    scenario 'founder is blocked from editing founders' do
      sign_in_user(founder.user, referer: admissions_founders_path)

      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  context 'when founder has compeleted the screening prerequisite' do
    let!(:tet_team_update) { create :timeline_event_type, :team_update }

    before do
      complete_target founder, screening_target
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

      # Number of founders and invited founders should be correct.
      expect(startup.founders.count).to eq(1)
      expect(startup.invited_founders.count).to eq(1)

      invited_founder = startup.invited_founders.first

      # Invited founder details should be correct.
      expect(invited_founder.name).to eq(name)
      expect(invited_founder.email).to eq(email)
      expect(invited_founder.phone).to eq(mobile)
      expect(invited_founder.college_text).to eq(college_name)

      # Invited founder should receive an email.
      open_email(email)

      expect(current_email).to have_content('You have been invited to join a startup at SV.CO.')
    end

    scenario 'founder invites another who has already completed payment', js: true do
      another_startup = create :level_0_startup
      payment = create :payment, :paid, startup: another_startup
      another_founder = another_startup.admin

      sign_in_user(founder.user, referer: admissions_founders_path)

      expect(page).to have_content('You are the team lead.')

      page.find('.founders-form__add-founder-button').click

      expect(page).to have_selector('.founders-form__founder-content-box', count: 2)

      within all('.founders-form__founder-content-box').last do
        fill_in 'Name', with: another_founder.name
        fill_in 'Email address', with: another_founder.email
        fill_in 'Mobile phone number', with: another_founder.phone
        select "My college isn't listed", from: 'College'
        fill_in 'Name of your college', with: Faker::Lorem.words(3).join(' ')
      end

      click_button 'Save founders'

      expect(page).to have_content('Details of founders have been saved!')

      # Invited startup should have changed.
      expect(another_founder.reload.invited_startup).to eq(startup)
      expect(another_founder.startup).to eq(another_startup)

      # Accept invitation.
      open_email(another_founder.email)

      expect(current_email).to have_content('You have been invited to join a startup at SV.CO.')

      click_here_path = '/' + current_email.find_link('click here')[:href].split('/')[-2..-1].join('/')
      visit click_here_path

      expect(page).to have_content "You have successfully joined #{founder.name}'s startup"

      # Payment should get refunded.
      expect(payment.reload.refunded?).to eq(true)
      expect(payment.startup).to eq(nil)

      # Founder should now be in the new startup.
      expect(another_founder.reload.startup).to eq(startup)
      expect(another_founder.invited_startup).to eq(nil)
    end

    scenario 'founder accepts invitation to another startup when already in a startup with other members' do
      another_startup = create :level_0_startup
      payment = create :payment, :paid, startup: another_startup
      another_founder = another_startup.admin
      another_founder.update!(invited_startup: startup, invitation_token: 'TEST_TOKEN')
      yet_another_founder = create :founder, startup: another_startup

      visit admissions_accept_invitation_path(token: 'TEST_TOKEN')

      # Payment should still exist.
      expect(payment.reload.refunded?).to eq(false)
      expect(payment.founder).to eq(another_founder)
      expect(payment.startup).to eq(another_startup)

      # yet_another_founder should now be the team lead.
      expect(another_startup.reload.admin).to eq(yet_another_founder)
      expect(another_startup.founders.count).to eq(1)
    end

    scenario 'a founder assumes role of team lead', js: true do
      another_founder = create :founder, startup: startup

      sign_in_user(another_founder.user, referer: admissions_founders_path)

      expect(page).to have_content("Your team lead is #{founder.name}.")

      accept_alert do
        click_button 'Become the team lead'
      end

      expect(page).to have_content('You are the team lead.')
      expect(startup.reload.admin).to eq(another_founder)
    end
  end

  context 'when the startup has already completed the initial payment' do
    let!(:tet_team_update) { create :timeline_event_type, :team_update }

    before do
      complete_target founder, screening_target
      complete_target founder, cofounder_addition_target
      complete_target founder, fee_payment_target
    end

    scenario 'founder is informed he cant edit the team anymore' do
      sign_in_user(founder.user, referer: admissions_founders_path)

      expect(page).to have_content('Team modifications are only allowed before you make your first payment')
    end
  end
end
