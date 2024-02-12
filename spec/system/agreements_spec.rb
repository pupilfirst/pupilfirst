require "rails_helper"

feature "User Agreements" do
  context "when the school has custom privacy policy" do
    let(:privacy_policy) { Faker::Lorem.paragraph(sentence_count: 10) }

    before { create :school_string, :privacy_policy, value: privacy_policy }

    it "displays privacy policy" do
      visit agreement_path(agreement_type: "privacy-policy")

      expect(page).to have_text(privacy_policy)
      expect(page).to have_link("Privacy Policy")
      expect(page).not_to have_link("Terms & Conditions")
    end
  end

  context "when the school has custom terms and conditions" do
    let(:terms_and_conditions) { Faker::Lorem.paragraph(sentence_count: 10) }

    before do
      create :school_string, :terms_and_conditions, value: terms_and_conditions
    end

    it "displays terms and conditions" do
      visit agreement_path(agreement_type: "terms-and-conditions")

      expect(page).to have_text(terms_and_conditions)
      expect(page).to have_link("Terms & Conditions")
      expect(page).not_to have_link("Privacy Policy")
    end
  end

  context "When school has code of conduct" do
    let(:code_of_conduct) { Faker::Lorem.paragraph(sentence_count: 10) }

    before { create :school_string, :code_of_conduct, value: code_of_conduct }

    it "displays code of conduct" do
      visit agreement_path(agreement_type: "code-of-conduct")

      expect(page).to have_text(code_of_conduct)
      expect(page).to have_link("Code of Conduct")
    end
  end

  context "when the school does not have custom agreement strings" do
    before { create :school, :current }

    it "404s on privacy policy page" do
      visit agreement_path(agreement_type: "privacy-policy")
      expect(page).to have_text("The page you were looking for doesn't exist")
    end

    it "404s on terms & conditions page" do
      visit agreement_path(agreement_type: "terms-and-conditions")
      expect(page).to have_text("The page you were looking for doesn't exist")
    end

    it "404s on code of conduct page" do
      visit agreement_path(agreement_type: "code-of-conduct")
      expect(page).to have_text("The page you were looking for doesn't exist")
    end
  end
end
