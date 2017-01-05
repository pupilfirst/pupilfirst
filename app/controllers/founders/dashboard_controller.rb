module Founders
  # TODO: This controller was introduced as part of the stalled auto-verification flow. Not excising it as the dashboard related code is scheduled to be moved here. See: https://trello.com/c/pGY1eOdG
  class DashboardController < ApplicationController
    before_action :authenticate_founder!

    # TODO: Used for stalled auto-verification flow. Excise or Re-use
    def toggle_auto_verified_target
      flash[:success] = "Target #{params[:target_id]} marked complete"
      redirect_to dashboard_founder_path
    end
  end
end
