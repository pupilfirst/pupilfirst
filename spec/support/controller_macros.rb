module ControllerMacros
  include Devise::TestHelpers

  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(:admin) # Using factory girl as an example
    end
  end

  def login_founder
    @request.env["devise.mapping"] = Devise.mappings[:founder]
    founder = FactoryGirl.create(:founder_with_out_password)
    # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
    @current_founder = founder
    sign_in @current_founder
  end
end
