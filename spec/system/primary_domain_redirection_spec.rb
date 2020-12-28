require 'rails_helper'

feature 'Primary Domain Redirection' do
  let(:school) { create :school, :current, configuration: { 'disable_primary_domain_redirection' => nil } }
  let(:student) { create :student }

  before do
    # Create another primary domain.
    school.domains.primary.update!(primary: false)
    @primary_domain = create :domain, :primary, school: school
  end

  it 'redirects to primary domain by default' do
    visit dashboard_path

    expect(page).to have_text("http://#{@primary_domain.fqdn}/dashboard")
  end

  context "when the configuration option is set" do
    let(:school) { create :school, :current, configuration: { 'disable_primary_domain_redirection' => true } }

    it 'does not redirect to primary domain' do
      visit dashboard_path

      expect(page).not_to have_text("http://#{@primary_domain.fqdn}/dashboard")
    end
  end
end
