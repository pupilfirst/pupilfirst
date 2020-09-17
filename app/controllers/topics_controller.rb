class TopicsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def show
    @topic = authorize(Topic.live.find(params[:id]))

    key = views_cache_key(@topic)

    # Increment views only once per hour per user.
    return if Rails.cache.exist?(key)

    @topic.increment!(:views) # rubocop:disable Rails/SkipsModelValidations
    Rails.cache.write(key, 1, expires_in: 1.hour)
  end

  def views_cache_key(topic)
    "topics/#{topic.id}/views/#{current_user.id}"
  end
end
