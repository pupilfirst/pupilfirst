class PostsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'
  after_action :verify_authorized

  def versions
    if current_coach
    @post = authorize(Post.live.find(params[:id]))
    else
      # redirect_to "/"
      raise_not_found
    end
  end
end
