require 'rails_helper'

feature 'User Agreements' do
  context 'when the school has custom privacy policy' do
    let(:privacy_policy) { Faker::Lorem.paragraph(sentence_count: 10) }

    before do
      create :school_string, :privacy_policy, value: privacy_policy
    end

    it 'displays privacy policy' do
      visit agreement_path(agreement_type: 'privacy-policy')

      expect(page).to have_text(privacy_policy)
      expect(page).to have_link('Privacy Policy')
      expect(page).not_to have_link('Terms of Use')
    end

    # Test the compatibility path
    it 'redirects from policies/privacy to new agreements path' do
      visit '/policies/privacy'
      expect(page).to have_text('Privacy Policy')
    end
  end

  context 'when the school has custom terms of use' do
    let(:terms_of_use) { Faker::Lorem.paragraph(sentence_count: 10) }

    before do
      create :school_string, :terms_of_use, value: terms_of_use
    end

    it 'displays terms of use' do
      visit agreement_path(agreement_type: 'terms-of-use')

      expect(page).to have_text(terms_of_use)
      expect(page).to have_link('Terms of Use')
      expect(page).not_to have_link('Privacy Policy')
    end

    # Test the compatibility path
    it 'redirects from policies/terms to new agreements path' do
      visit '/policies/terms'
      expect(page).to have_text('Terms of Use')
    end
  end

  context 'when the school does not have custom agreement strings' do
    before do
      create :school, :current
    end

    it '404s on privacy policy page' do
      visit agreement_path(agreement_type: 'privacy-policy')
      expect(page).to have_text("The page you were looking for doesn't exist")
    end

    it '404s on terms of use page' do
      visit agreement_path(agreement_type: 'terms-of-use')
      expect(page).to have_text("The page you were looking for doesn't exist")
    end
  end
end
