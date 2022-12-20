module CalendarEvents
  class CreateOrUpdateForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :id,
                  :title,
                  :description,
                  :calendar_id,
                  :color,
                  :start_time,
                  :link_url,
                  :link_title

    validates :title,
              presence: {
                message: 'Please enter a valid title for the event'
              }
    validates :calendar_id,
              presence: {
                message: 'Please select a calendar from the list'
              }
    validates :color,
              presence: {
                message: 'Please select a color for the event'
              }
    validates :start_time,
              presence: {
                message: 'Please select a valid time for the event'
              }

    validate :start_time_is_valid
    validate :link_url_is_valid

    def start_time_is_valid
      begin
        time = Time.zone.parse(start_time)
        if time.blank?
          errors.add(:base, 'Please enter a valid time for the event')
        end
      rescue StandardError
        errors.add(:base, 'Please enter a valid time for the event')
      end
    end

    def link_url_is_valid
      return if link_url.blank?

      begin
        URI.parse(link_url)
      rescue StandardError
        errors.add(:base, 'Please enter a valid URL for the event')
      end
    end

    def save
      return false unless valid?

      calendar_event = CalendarEvent.find_or_initialize_by(id: id)
      calendar_event.attributes = {
        title: title,
        description: description,
        calendar_id: calendar_id,
        color: color,
        start_time: start_time,
        link_url: link_url,
        link_title: link_title
      }
      calendar_event.save!
      calendar_event
    end
  end
end
