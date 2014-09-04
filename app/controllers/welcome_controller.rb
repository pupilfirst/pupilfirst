class WelcomeController < ApplicationController
  layout 'home'

  def index
    if current_user
      redirect_to current_user
    end
  end

  def team

  end
end
