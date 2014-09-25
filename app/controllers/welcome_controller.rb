class WelcomeController < ApplicationController
  def index
    if current_user
      redirect_to current_user
    end

    @full_width = true
  end

  def team

  end
end
