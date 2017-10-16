class PlayerMailer < ApplicationMailer
  def welcome(player)
    @player = player
    mail(to: @player.user.email, subject: "Welcome to the SV.CO TechHunt!")
  end
end
