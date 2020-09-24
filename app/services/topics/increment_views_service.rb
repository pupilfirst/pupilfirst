module Topics
  class IncrementViewsService
    def initialize(topic)
      @topic = topic
    end

    def execute(user)
      key = views_cache_key(user)

      # Increment views only once per hour per user.
      return if Rails.cache.exist?(key)

      @topic.increment!(:views) # rubocop:disable Rails/SkipsModelValidations
      Rails.cache.write(key, 1, expires_in: 1.hour)
    end

    def views_cache_key(user)
      "topics/#{@topic.id}/views/#{user.id}"
    end
  end
end
