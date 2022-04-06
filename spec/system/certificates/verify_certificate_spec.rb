require 'rails_helper'

feature 'Certificate verification', js: true do
  include UserSpecHelper

  let!(:issued_certificate) { create :issued_certificate }
  let(:user) { issued_certificate.user }

  around do |example|
    Time.use_zone(user&.time_zone || 'UTC') { example.run }
  end

  scenario 'user verifies certificate' do
    sign_in_user user, referrer: issued_certificate_path(serial_number: issued_certificate.serial_number)

    expect(page).to have_text(user.name)
    expect(page).to have_text(issued_certificate.certificate.course.name)
    expect(page).to have_text(issued_certificate.created_at.strftime('%b %-d, %Y'))
    expect(page).not_to have_text("This student's name was updated after the certificate was issued.")
  end

  scenario 'a member of the public verifies the certificate' do
    visit issued_certificate_path(serial_number: issued_certificate.serial_number)

    expect(page).to have_text(user.name)
    expect(page).to have_text(issued_certificate.certificate.course.name)
    expect(page).to have_text(issued_certificate.created_at.strftime('%b %-d, %Y'))
  end

  context 'when the user changes her name after the certificate is issued' do
    let!(:issued_certificate) { create :issued_certificate, name: Faker::Name.name }

    scenario 'both the name at the time of issuance and current name are shown on verification page' do
      visit issued_certificate_path(serial_number: issued_certificate.serial_number)

      expect(page).to have_text("This student's name was updated after the certificate was issued.")
      expect(page).to have_text(user.name)
      expect(page).to have_text(issued_certificate.name)
    end
  end

  context 'user is not present' do
    let!(:issued_certificate) { create :issued_certificate, name: Faker::Name.name, user: nil }

    scenario 'a member of public verifies the certificate' do
      visit issued_certificate_path(serial_number: issued_certificate.serial_number)

      expect(page).to have_text(issued_certificate.name)
      expect(page).to have_text(issued_certificate.certificate.course.name)
    end
  end
end
