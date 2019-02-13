require 'rails_helper'

feature 'Connect Request Comment' do
  include UserSpecHelper

  let(:faculty) { create :faculty }
  let(:startup) { create :startup }
  let(:founder) { startup.founders.first }
  let(:connect_slot) { create :connect_slot, faculty: faculty }

  let(:connect_request) { create :connect_request, connect_slot: connect_slot, startup: startup }

  let(:rating) { rand(1..5) }
  let(:comment) { Faker::Lorem.sentence }

  scenario 'Faculty visits comment submit page' do
    visit connect_request_feedback_from_faculty_url(id: connect_request.id, token: faculty.token, rating: rating)
    expect(page).to have_text('Do you have any additional feedback for SV.CO team?')
    fill_in 'Do you have any additional feedback for SV.CO team?', with: comment
    click_button 'Submit'
    expect(connect_request.reload.comment_for_team).to eq(comment)
  end

  scenario 'Founder visits comment submit page' do
    visit connect_request_feedback_from_team_url(id: connect_request.id, token: founder.auth_token, rating: rating)
    expect(page).to have_text('Do you have any additional feedback for SV.CO team?')
    fill_in 'Do you have any additional feedback for SV.CO team?', with: comment
    click_button 'Submit'
    expect(connect_request.reload.comment_for_faculty).to eq(comment)
  end
end
