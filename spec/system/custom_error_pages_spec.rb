require 'rails_helper'

feature 'Custom Error Pages' do
  around do |example|
    original_pupilfirst_domains = Rails.application.secrets.pupilfirst_domains
    Rails.application.secrets.pupilfirst_domains = %w[test.host]

    example.run

    Rails.application.secrets.pupilfirst_domains = original_pupilfirst_domains
  end

  scenario 'User visits non-existent page' do
    visit '/non_existent_page'

    expect(page).to have_text("The page you were looking for doesn't exist")
    expect(page).to have_text('You may have mistyped the address, or the page may have moved.')
  end

  scenario 'User visits page which raises an error' do
    allow_any_instance_of(HomeController).to receive(:index).and_raise(ArgumentError)

    visit root_path

    expect(page).to have_text("We're sorry, but something went wrong.")
    expect(page).to have_text('We track these errors automatically')
  end
end
