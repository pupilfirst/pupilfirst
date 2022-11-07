class PostsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def versions
    @post = authorize(Post.live.find(params[:id]))
    raise_not_found unless current_coach
  end
end
