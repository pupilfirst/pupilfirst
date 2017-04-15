require 'rails_helper'

feature 'Editing founders during admission' do
  include UserSpecHelper
  include FounderSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.admin }
  let!(:screening_target) { create :target, :admissions_screening }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment }

  context "when founder hasn't completed prerequisites" do
    it 'blocks founder from editing founders' do
      sign_in_user(founder.user, referer: admissions_founders_path)

      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  context 'when founder has compeleted prerequisites' do
    before do
      complete_target founder, screening_target
      complete_target founder, fee_payment_target
    end

    it 'allows founder to manage founder details', js: true do
      sign_in_user(founder.user, referer: admissions_founders_path)

      expect(page).to have_content('You are the team lead.')
    end
  end

  # scenario 'applicant adds cofounder details', js: true do
  #   # user signs in
  #   sign_in_user(batch_applicant.user, referer: apply_continue_path)
  #
  #   expect(page).to have_content('Build your dream startup team now')
  #   click_link('Add cofounder details')
  #
  #   # The page should ask for details of one co-founder.
  #   expect(page).to have_selector('.cofounder.content-box', count: 1)
  #
  #   # Add another, and fill in details for two.
  #   name = Faker::Name.name
  #   fill_in 'Name', with: name
  #   fill_in 'Email address', with: Faker::Internet.email(name)
  #   fill_in 'Mobile phone number', with: (9_876_543_210 + rand(1000)).to_s
  #   select "My college isn't listed", from: 'College'
  #   fill_in 'Name of your college', with: Faker::Lorem.words(3).join(' ')
  #
  #   # The link doesn't have an href. Hence find to click.
  #   page.find('.cofounders-form__add-cofounder-button').click
  #
  #   expect(page).to have_selector('.cofounder.content-box', count: 2)
  #
  #   within all('.cofounder.content-box').last do
  #     name = Faker::Name.name
  #     fill_in 'Name', with: name
  #     fill_in 'Email address', with: Faker::Internet.email(name)
  #     fill_in 'Mobile phone number', with: (9_876_543_210 + rand(1000)).to_s
  #     select "My college isn't listed", from: 'College'
  #     fill_in 'Name of your college', with: Faker::Lorem.words(3).join(' ')
  #   end
  #
  #   click_button 'Save cofounders'
  #
  #   expect(page).to have_content(/edit cofounder details/i)
  #
  #   # Ensure that the cofounders have been stored.
  #   expect(batch_application.cofounders.count).to eq(2)
  # end
end
