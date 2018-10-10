module StartupQuotes
  # Stores the latest quotes from startupquotes.startupvitamins.com (RSS feed).
  class CollectService
    include Loggable

    RSS_URL = -'http://startupquotes.startupvitamins.com/rss'

    def execute(feed_url: RSS_URL)
      require 'rss'

      log "Loading RSS URL: #{feed_url}"

      uri = URI(RSS_URL)
      rss = Net::HTTP.get(uri)
      feed = ::RSS::Parser.parse(rss)

      feed.items.each do |item|
        guid = item.guid.content

        # Stop writing feed items we've encountered on we've stored before.
        break if StartupQuote.find_by(guid: guid).present?

        # Add to stored quotes.
        StartupQuote.create!(guid: guid, link: item.link)
      end
    end

    # Reloads the entire startup quote database.
    def reload(run: false, max_page: 78)
      raise "Do you know what you're doing?" unless run

      (3..max_page).each do |page|
        execute(feed_url: "http://startupquotes.startupvitamins.com/page/#{page}/rss")

        # Sleep so that we don't send a deluge of requests.
        sleep 1
      end
    end
  end
end
