require 'rails_helper'

feature 'Prospective Applicants' do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email(name) }
  let(:phone) { rand(9_876_543_000..9_876_550_000).to_s }
  let(:college_name) { Faker::Lorem.words(3).join(' ') }

  around(:example) do |example|
    Feature.skip_override = true
    example.run
    Feature.skip_override = false
  end

  context 'when no batch is open for applications' do
    scenario 'user can register for notification', js: true do
      visit apply_path
      expect(page).to have_content('Admissions are closed')

      fill_in 'Name', with: name
      fill_in 'Email', with: email
      fill_in 'Phone', with: phone

      # Search for college...
      first('.select2-container', minimum: 1).click
      find('.select2-dropdown input.select2-search__field').send_keys(college_name)

      # ...it will not be available.
      find('.select2-results__option--highlighted', text: "My college isn't listed").click

      # So type the name in manually.
      fill_in 'College', with: college_name

      click_on 'Notify Me'

      expect(page).to have_content("Thank you for your interest! We'll send you an email when admissions open")

      expect(ProspectiveApplicant.count).to eq(1)
      last_applicant = ProspectiveApplicant.last

      expect(last_applicant.name).to eq(name)
      expect(last_applicant.email).to eq(email)
      expect(last_applicant.phone).to eq(phone)
      expect(last_applicant.college_text).to eq(college_name)
    end
  end
end
