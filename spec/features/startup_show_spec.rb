require 'rails_helper'

feature 'Startup Show' do
  let(:founder) { create :founder, confirmed_at: Time.now }
  let!(:startup) { create :startup }
  let(:target) { create :target, rubric: Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')) }

  before :each do
    startup.founders << founder
    target.update(assignee: startup)

    # Log in the founder.
    visit user_token_path(token: founder.user.login_token)
  end

  context 'Founder visits show page of his startup' do
    scenario 'Founder views a rubric file' do
      expect(page).to have_content(startup.product_name)
      expect(page).to have_content(target.title)

      click_on 'Download Rubric'
      expect(current_path).to eq(target.rubric.url)
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
    end
  end
end
