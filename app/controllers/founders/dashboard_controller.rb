module Founders
  # TODO: This controller was introduced as part of the stalled auto-verification flow. Not excising it as the dashboard related code is scheduled to be moved here. See: https://trello.com/c/pGY1eOdG
  class DashboardController < ApplicationController
    before_action :authenticate_founder!
  end
end
