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
                message:
                  I18n.t('calendar_events.create_or_update_form.title_error')
              }
    validates :calendar_id,
              presence: {
                message:
                  I18n.t('calendar_events.create_or_update_form.calendar_error')
              }
    validates :color,
              presence: {
                message:
                  I18n.t('calendar_events.create_or_update_form.color_error')
              }
    validates :start_time,
              presence: {
                message:
                  I18n.t(
                    'calendar_events.create_or_update_form.start_time_error'
                  )
              }

    validate :start_time_is_valid
    validate :link_url_is_valid

    def start_time_is_valid
      begin
        time = Time.zone.parse(start_time)
        if time.blank?
          errors.add(
            :base,
            I18n.t('calendar_events.create_or_update_form.start_time_error')
          )
        end
      rescue StandardError
        errors.add(
          :base,
          I18n.t('calendar_events.create_or_update_form.start_time_error')
        )
      end
    end

    def link_url_is_valid
      return if link_url.blank?

      begin
        URI.parse(link_url)
      rescue StandardError
        errors.add(
          :base,
          I18n.t('calendar_events.create_or_update_form.invalid_url')
        )
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
