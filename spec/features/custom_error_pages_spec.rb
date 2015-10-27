require 'rails_helper'

feature 'Custom Error Pages' do
  scenario 'User visits non-existent page' do
    visit '/non_existent_page'

    expect(page).to have_text("The page you were looking for doesn't exist.")
    expect(page).to have_text('You may have mistyped the address, or the page may have moved.')
  end

  scenario 'User visits page which raises an error' do
    allow_any_instance_of(HomeController).to receive(:index).and_raise(ArgumentError)

    visit root_path

    expect(page).to have_text("We're sorry, but something went wrong.")
    expect(page).to have_text('This could be because SV.CO is under active development!')
    expect(page).to have_text('Please try again after a while, or contact us on our Public Slack Channel.')
  end
end
