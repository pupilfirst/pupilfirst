module Students
  class ResetProgressService
    # @param student [Student] The student for whom the progress needs to be reset.
    # @param executor [Object] The user who is resetting the progress.
    def initialize(student, executor)
      @student = student
      @executor = executor
    end

    def reset
      Student.transaction do
        @student.timeline_events.live.includes(:timeline_event_owners).each do |submission|
          # Skip if the submission has multiple owners
          next if submission.timeline_event_owners.count > 1

          submission.update!(archived_at: Time.zone.now)
          submission.timeline_event_owners.each { |owner| owner.update!(latest: false) }
        end
        # Delete all page reads
        @student.page_reads.delete_all
        # Reset the 'completed at' timestamp
        @student.update!(completed_at: nil)
        # Add a coach note indicating the reset
        @student.coach_notes.create!(note: I18n.t("services.students.reset_progress_service.reset_note"), author: @executor)
      end
    end
  end
end
