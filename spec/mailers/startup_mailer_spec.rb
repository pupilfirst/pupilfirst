require "spec_helper"

describe 'StartupMailer' do
  include Rails.application.routes.url_helpers

  context 'shoot out emails to all founders' do
    before(:all) do
      @startup = create :startup
      @new_employee = create :user_with_out_password
      @email = StartupMailer.respond_to_new_employee(@startup, @new_employee)
    end

    it "with to set as founders email" do
      @email.should deliver_to(@startup.founders.map { |e| "#{e.fullname} <#{e.email}>" })
    end

    it "with body containing a link to the confirmation link" do
      @email.should have_body_text(/#{confirm_employee_startup_url(@startup, token: @new_employee.startup_verifier_token)}/)
    end

    it "with subject \"Approve new employee at \#{@startup.name}\"" do
      @email.should have_subject(/Approve new employee at #{@startup.name}/)
    end
  end
end
