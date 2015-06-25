class HomeController < ApplicationController
  layout 'demo'

  def index
    @blogs = get_latest_blogs
  end

  private

  def get_latest_blogs
    [1,2]
  end

end

