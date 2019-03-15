module FacultyModule
  class WeeklySlotsPromptJob < ApplicationJob
    queue_as :default

    def perform
      # Prompt faculty to record available connect slots for the upcoming week
      Faculty.where(self_service: true).each do |faculty|
        # copy last available set of weekly slots
        faculty.copy_weekly_slots!
        Rails.logger.info "Sending Mail to #{faculty.name}"
        FacultyMailer.request_next_week_slots(faculty).deliver_later
      end
    end
  end
end
