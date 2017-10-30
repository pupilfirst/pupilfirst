class PlayerMailerPreview < ActionMailer::Preview
  def welcome
    user = User.new(login_token: 'LOGIN_TOKEN')
    player = Player.new(user: user, name: 'Sherlock Holmes')
    PlayerMailer.welcome(player)
  end
end
