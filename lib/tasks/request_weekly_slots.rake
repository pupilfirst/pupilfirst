desc 'Send out e-mails to self-service faculty requesting connect slots available for upcoming week'
task request_weekly_slots: [:environment] do
  FacultyModule::WeeklySlotsPromptJob.perform_later
end
