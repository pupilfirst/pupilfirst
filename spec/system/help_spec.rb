require 'rails_helper'

feature 'Help pages', js: true do
  before do
    create :school, :current
  end

  scenario 'User visits the markdown editor help page' do
    visit '/help/markdown_editor'
    expect(page).to have_text('Markdown is a method to add styling for your text on the web.')
  end
end
