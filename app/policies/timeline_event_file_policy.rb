class TimelineEventFilePolicy < ApplicationPolicy
  def download?
    return false if user.founders.blank? && current_coach.blank?

    timeline_event = record.timeline_event

    # Allow everyone to download unlinked files. These have just been uploaded by a user, using the submission interface
    # and will be deleted by DatabaseCleanupJob#cleanup_submission_files if still unlinked after 24 hours.
    return true if timeline_event.blank?

    students = timeline_event.founders

    # Coaches can view submission files.
    return true if current_user_coaches?(timeline_event.target.course, students)

    # Team members linked directly to the submission can access attached files.
    students.exists?(user_id: user&.id)
  end

  def create?
    # User must be enrolled as a student.
    return false if user.founders.empty?

    # At least one of the student profiles must be non-exited AND non-ended (course AND access).
    user
      .founders
      .includes(:cohort)
      .any? { |founder| !(founder.dropped_out_at? || founder.access_ended?) }
  end

  private

  def current_user_coaches?(course, founders)
    return false if current_coach.blank?

    # Current user is a coach if he has been linked as reviewer to entire course holding this TEF.
    return true if current_coach.courses.exists?(id: course)

    # Current user is a coach if he has been linked as reviewer directly to any student that TE founders are currently
    # a part of.
    current_coach.founders.exists?(id: founders)
  end
end
