module ControllerMacros
  include Devise::TestHelpers

  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(:admin) # Using factory girl as an example
    end
  end

  def login_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:founder_with_out_password)
    # user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
    @current_user = user
    sign_in @current_user
  end
end
