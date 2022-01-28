module UserSpecHelper
  # @param user [User] User to log in
  # @param referrer [String] (Optional) path to which user should be redirected after signing in.
  def sign_in_user(user, referrer: nil)
    user.regenerate_login_token
    login_token = user.original_login_token
    sign_in_path = user_token_path(token: login_token, referrer: referrer)
    visit(sign_in_path)
  end
end
