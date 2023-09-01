class TimelineEventFilePolicy < ApplicationPolicy
  def download?
    return false if user.blank?

    timeline_event = record.timeline_event

    # Allow everyone to download unlinked files. These have just been uploaded by a user, using the submission interface
    # and will be deleted by DatabaseCleanupJob#cleanup_submission_files if still unlinked after 24 hours.
    return true if timeline_event.blank?

    students = timeline_event.students

    # Coaches can view submission files.
    return true if current_user_coaches?(timeline_event.target.course, students)

    # Team members linked directly to the submission can access attached files.
    return true if students.exists?(user_id: user.id)

    # School admins can access files
    return true if current_school_admin.present?

    # Organisation admins can access files
    organisation = students.first.user.organisation

    return false if organisation.blank?

    user.organisations.exists?(id: record.user.organisation_id)
  end

  def create?
    # User must be enrolled as a student.
    return false if user.students.empty?

    # At least one of the student profiles must be non-exited AND non-ended (course AND access).
    user
      .students
      .includes(:cohort)
      .any? { |student| !(student.dropped_out_at? || student.access_ended?) }
  end

  private

  def current_user_coaches?(course, students)
    return false if current_coach.blank?

    # Current user is a coach if he has been linked as reviewer to entire course holding this TEF.
    return true if current_coach.courses.exists?(id: course)

    # Current user is a coach if he has been linked as reviewer directly to any student that TE students are currently
    # a part of.
    current_coach.students.exists?(id: students)
  end
end
