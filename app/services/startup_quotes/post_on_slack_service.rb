module StartupQuotes
  class PostOnSlackService
    def execute
      # Fetch the least posted, oldest startup quote.
      startup_quote = StartupQuote.order(post_count: :asc, created_at: :asc).first

      # Post it on #community.
      api.post(message: startup_quote.link, channel: '#community')

      # Increase the post count for 'this' quote.
      startup_quote.post_count += 1
      startup_quote.save!
    end

    private

    def api
      @api ||= PublicSlack::MessageService.new(unfurl_links: true)
    end
  end
end
