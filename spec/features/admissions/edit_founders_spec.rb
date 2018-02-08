require 'rails_helper'

feature 'Edit founders' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.team_lead }
  let(:level_0) { create :level, :zero }
  let!(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:cofounder_addition_target) { create :target, :admissions_cofounder_addition, target_group: level_0_targets }

  context "when founder hasn't completed the screening prerequisites" do
    scenario 'founder is blocked from editing founders' do
      sign_in_user(founder.user, referer: admissions_team_members_path)

      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  context 'when founder has completed the screening prerequisite' do
    let!(:tet_team_update) { create :timeline_event_type, :team_update }

    before do
      complete_target founder, screening_target
    end

    scenario 'founder adds a cofounder', js: true do
      sign_in_user(founder.user, referer: admissions_team_members_path)

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

      click_button 'Save details'

      expect(page).to have_content('Details of team members have been saved!')

      # The cofounder addition target should have been completed.
      expect(cofounder_addition_target.status(founder)).to eq(Targets::StatusService::STATUS_COMPLETE)

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

      expect(current_email).to have_content('You have been invited to join a team')
    end

    scenario 'a founder assumes role of team lead', js: true do
      another_founder = create :founder, startup: startup

      sign_in_user(another_founder.user, referer: admissions_team_members_path)

      expect(page).to have_content("Your team lead is #{founder.name}.")

      accept_alert do
        click_button 'Become the team lead'
      end

      expect(page).to have_content('You are the team lead.')
      expect(startup.reload.team_lead).to eq(another_founder)
    end

    scenario 'founder invites another from a higher level', js: true do
      admitted_lead = create(:startup).team_lead

      sign_in_user(founder.user, referer: admissions_team_members_path)

      expect(page).to have_content('You are the team lead.')

      page.find('.founders-form__add-founder-button').click

      expect(page).to have_selector('.founders-form__founder-content-box', count: 2)

      within all('.founders-form__founder-content-box').last do
        fill_in 'Name', with: admitted_lead.name
        fill_in 'Email address', with: admitted_lead.email
        fill_in 'Mobile phone number', with: admitted_lead.phone
        select "My college isn't listed", from: 'College'
        fill_in 'Name of your college', with: Faker::Lorem.words(3).join(' ')
      end

      click_button 'Save details'

      expect(page).to have_content("It looks like you've attempted to invite users who have already joined the SV.CO program.")
      expect(page).to have_content('is already an admitted SV.CO user')
    end

    scenario 'founder makes a possible mistake in the email, gets an email hint and accepts it', js: true do
      sign_in_user(founder.user, referer: admissions_team_members_path)

      page.find('.founders-form__add-founder-button').click

      name = Faker::Name.name
      college_name = Faker::Lorem.words(3).join(' ')
      mobile = '8976543210'

      within all('.founders-form__founder-content-box').last do
        fill_in 'Name', with: name
        fill_in 'Email address', with: 'test@gamil.com'
        fill_in 'Mobile phone number', with: mobile
        select "My college isn't listed", from: 'College'
        fill_in 'Name of your college', with: college_name
      end

      click_button 'Save details'

      expect(page).to have_content("It looks like you've entered an invalid email address")

      within all('.founders-form__founder-content-box').last do
        expect(page).to have_text('Did you mean test@gmail.com?')
        find('#founder-form__password-hint-accept').click
      end

      click_button 'Save details'
      expect(page).to have_content('Details of team members have been saved!')

      last_founder = Founder.last
      expect(last_founder.email).to eq('test@gmail.com')
    end

    scenario 'founder makes a possible mistake in the email, gets an email hint and rejects it', js: true do
      sign_in_user(founder.user, referer: admissions_team_members_path)

      page.find('.founders-form__add-founder-button').click

      name = Faker::Name.name
      college_name = Faker::Lorem.words(3).join(' ')
      mobile = '8976543210'

      within all('.founders-form__founder-content-box').last do
        fill_in 'Name', with: name
        fill_in 'Email address', with: 'test@gamil.com'
        fill_in 'Mobile phone number', with: mobile
        select "My college isn't listed", from: 'College'
        fill_in 'Name of your college', with: college_name
      end

      click_button 'Save details'

      expect(page).to have_content("It looks like you've entered an invalid email address")

      within all('.founders-form__founder-content-box').last do
        expect(page).to have_text('Did you mean test@gmail.com?')
        find('#founder-form__password-hint-reject').click
      end

      click_button 'Save details'
      expect(page).to have_content('Details of team members have been saved!')

      last_founder = Founder.last
      expect(last_founder.email).to eq('test@gamil.com')
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
      sign_in_user(founder.user, referer: admissions_team_members_path)

      expect(page).to have_content('You have already paid for your current team!')
    end
  end
end
