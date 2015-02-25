include Warden::Test::Helpers

module DeviseHelpers
  def login(user = nil)
    user ||= FactoryGirl.create(:user_with_out_password)
    login_as user, scope: :user
    user
  end
end
