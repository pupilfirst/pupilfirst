require 'spec_helper'

describe "startups/index" do
  before(:each) do
    assign(:startups, [
      stub_model(Startup,
        :name => "Name",
        :logo => "Logo",
        :pitch => "Pitch",
        :website => "Website",
        :about => "About",
        :tags => "",
        :email => "Email",
        :phone => "Phone"
      ),
      stub_model(Startup,
        :name => "Name",
        :logo => "Logo",
        :pitch => "Pitch",
        :website => "Website",
        :about => "About",
        :tags => "",
        :email => "Email",
        :phone => "Phone"
      )
    ])
  end

  it "renders a list of startups" do
    assign(:current_user, FactoryGirl.build(:user, startup: Startup.first))
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Pitch".to_s, :count => 2
    assert_select "tr>td", :text => "Website".to_s, :count => 2
    assert_select "tr>td", :text => "About".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Phone".to_s, :count => 2
  end
end
