module Coaches
  class DashboardController < ApplicationController
    def index
      @skip_container = true
    end
  end
end
