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
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Logo/)
    expect(rendered).to match(/Pitch/)
    expect(rendered).to match(/Website/)
    expect(rendered).to match(/About/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Phone/)
    expect(rendered).to match(/Categories/)
    expect(rendered).to match(/Facebook Link/)
    expect(rendered).to match(/Twitter Link/)
  end
end
