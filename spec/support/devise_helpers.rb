# TODO: This file might not be required. It's not the recommended way to login, logout for integration tests, anyway.

include Warden::Test::Helpers
Warden.test_mode!

module DeviseHelpers
  def login(user = nil)
    user ||= FactoryGirl.create(:founder_with_out_password)
    login_as user, scope: :user
    user
  end
end
