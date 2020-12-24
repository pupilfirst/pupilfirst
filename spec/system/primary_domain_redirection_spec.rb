require 'rails_helper'

feature 'Primary Domain Redirection' do
  let(:school) { create :school, :current, configuration: { 'redirect_to_primary_domain' => true } }
  let(:student) { create :student }

  before do
    # Create another primary domain.
    school.domains.primary.update!(primary: false)
    @primary_domain = create :domain, :primary, school: school
  end

  it 'redirects to primary domain when appropriate config is set' do
    visit dashboard_path

    expect(page).to have_text("http://#{@primary_domain.fqdn}/dashboard")
  end

  context "when the configuration option isn't set" do
    let(:school) { create :school, :current }

    it 'does not redirect to primary domain' do
      visit dashboard_path

      expect(page).not_to have_text("http://#{@primary_domain.fqdn}/dashboard")
    end
  end
end
