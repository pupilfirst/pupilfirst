module UserSpecHelper
  # @param user [User] User to log in
  # @param referer [String] (Optional) path to which user should be redirected after signing in.
  def sign_in_user(user, referer: nil)
    user.regenerate_login_token if user.login_token.blank?
    sign_in_path = user_token_path(token: user.login_token, referer: referer)
    visit(sign_in_path)
  end
end
