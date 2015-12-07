class FacultyWeeklySlotsPromptJob < ActiveJob::Base
  queue_as :default

  def perform
    # Prompt faculty to record available connect slots for the upcoming week
    Faculty.where(self_service: true).each do |faculty|
      puts "Sending Mail to #{faculty.name}"
      FacultyMailer.request_next_week_slots(faculty).deliver_later
    end
  end
end
