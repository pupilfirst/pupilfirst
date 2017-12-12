class GoogleCalendarService
  delegate :create_event, :find_or_create_event_by_id, to: :@google_calendar

  def initialize
    @google_calendar = Google::Calendar.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      redirect_url: ENV['GOOGLE_OAUTH_REDIRECT_URL'],
      calendar: ENV['GOOGLE_CALENDAR_ID'],
      refresh_token: ENV['GOOGLE_REFRESH_TOKEN']
    )
  end

  # This method can be used to regenerate the refresh token if the authorization fails, for whatever reason. Just run
  # this method from console using `GoogleCalendarService.refresh`.
  #
  # rubocop:disable Rails/Output, Metrics/MethodLength, Metrics/AbcSize
  def self.refresh
    cal = Google::Calendar.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      redirect_url: ENV['GOOGLE_OAUTH_REDIRECT_URL'],
      calendar: ENV['GOOGLE_CALENDAR_ID']
    )

    puts 'Visit the following web page in your browser and approve access.'
    puts cal.authorize_url
    puts "\nCopy the code that Google returned and paste it here:"

    # Pass the ONE TIME USE access code here to login and get a refresh token that you can use for access from now on.
    refresh_token = cal.login_with_auth_code($stdin.gets.chomp)

    puts "\nMake sure you SAVE YOUR REFRESH TOKEN so you don't have to prompt the user to approve access again."
    puts "Your new GOOGLE_REFRESH_TOKEN is:\n\t#{refresh_token}\n"
    puts "I'll create and update a test event to ensure everything is working. Press return to continue."
    $stdin.gets.chomp

    event = cal.create_event do |e|
      e.title = 'A Cool Event'
      e.start_time = Time.now
      e.end_time = Time.now + (60 * 60) # seconds * min
    end

    puts event

    event = cal.find_or_create_event_by_id(event.id) do |e|
      e.title = 'An Updated Cool Event'
      e.end_time = Time.now + (60 * 60 * 2) # seconds * min * hours
    end

    puts event

    # All events
    puts cal.events

    # Query events
    puts cal.find_events('your search string')
  end
  # rubocop:enable Rails/Output, Metrics/MethodLength, Metrics/AbcSize
end
