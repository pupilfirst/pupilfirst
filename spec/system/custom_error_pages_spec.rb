require 'rails_helper'

feature 'Custom Error Pages' do
  scenario 'User visits non-existent page' do
    visit '/non_existent_page'

    expect(page).to have_text("The page you were looking for doesn't exist.")
    expect(page).to have_text('You may have mistyped the address, or the page may have moved.')
  end
end
