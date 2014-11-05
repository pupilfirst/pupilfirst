require 'spec_helper'

describe "startups/show" do
  before(:each) do
    @startup = assign(:startup, stub_model(Startup,
      :name => "Name",
      :logo => "Logo",
      :pitch => "Pitch",
      :website => "Website",
      :about => "About",
      :tags => "",
      :email => "Email",
      :phone => "Phone1"
    ))

    @new_startup_link = assign(:new_startup_link, stub_model(StartupLink))

    view.stub_chain :current_user, :is_founder? => false
  end

  it 'renders attributes in table' do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Presentation/)
    expect(rendered).to match(/Founders/)
    expect(rendered).to match(/Website/)
    expect(rendered).to match(/Categories/)
  end
end
