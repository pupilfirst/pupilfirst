module Coaches
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def index
      authorize %i[coaches dashboard]
      @skip_container = true
    end
  end
end
