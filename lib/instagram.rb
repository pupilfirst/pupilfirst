# Used to load latest images from our Instagram account - 'svdotco'.
class Instagram
  def self.load_latest_images(count: 6)
    return [] if Rails.env.test?

    @instagram_images = cached_response(count)[:data].each_with_object([]) do |data, results|
      results << {
        image_url: data[:images][:standard_resolution][:url],
        instagram_link: data[:link],
        likes_count: data[:likes][:count],
        comments_count: data[:comments][:count],
        tags: data[:tags]
      }

      next if data[:caption].blank?

      results.last[:caption] = {
        text: data[:caption][:text],
        created_at: data[:caption][:created_time]
      }
    end
  end

  def self.cached_response(count)
    Rails.cache.fetch(cache_key(count), expires_in: 1.hour) do
      response = begin
        puts 'Contacting Instagram API. This should occur only once per hour per process.'
        load_from_api(count)
      rescue RestClient::Exception
        Rails.cache.fetch(cache_backup_key(count), expires_in: 24.hours) do
          puts 'Contacting Instagram API. Backup cache has expired. Something is probably wrong...'
          load_from_api(count, cache_backup: false)
        end
      end

      JSON.parse(response).with_indifferent_access
    end
  end

  def self.load_from_api(count, cache_backup: true)
    response = RestClient.get(
      'https://api.instagram.com/v1/users/self/media/recent/',
      params: {
        access_token: Rails.application.secrets.instagram_access_token,
        count: count
      }
    )

    Rails.cache.write(cache_backup_key(count), response, expires_in: 24.hours) if cache_backup

    response
  end

  def self.cache_key(count)
    "instagram/latest_images/#{count}"
  end

  def self.cache_backup_key(count)
    "instagram/latest_images/#{count}/backup"
  end
end
