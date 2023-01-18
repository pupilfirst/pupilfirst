require_relative 'helper'

after 'development:calendars' do
  puts 'Seeding calendar events'

  Calendar.all.each do |calendar|
    10.times do
      calendar.calendar_events.create!(
        title: Faker::Lorem.words(number: 3).join(' '),
        description: Faker::Lorem.words(number: 5).join(' '),
        color: %w[blue green yellow].sample,
        start_time:
          Faker::Time.between(
            from: DateTime.now + 1.day,
            to: DateTime.now + 10.days
          ),
        link_url: Faker::Internet.url,
        link_title: Faker::Lorem.words(number: 3).join(' ')
      )
    end
  end
end
