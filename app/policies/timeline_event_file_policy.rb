class TimelineEventFilePolicy < ApplicationPolicy
  def download?
    return false if user.blank?

    timeline_event = record.timeline_event

    # The unlinked file should be only downloadable by the uploader.
    return true if timeline_event.blank? && user == record.user

    return false if timeline_event.blank?

    return true if timeline_event.hidden_at.present? && user == record.user

    return false if timeline_event.hidden_at.present?

    students = timeline_event.students
    target = timeline_event.target
    course = target.course

    # Coaches can view submission files.
    return true if current_user_coaches?(course, students)

    # Team members linked directly to the submission can access attached files.
    return true if students.exists?(user_id: user.id)

    # School admins can access files
    return true if current_school_admin.present?

    # Organisation admins can access files
    organisation = students.first.user.organisation

    # Return true if requesting user is enrolled in the same course and the assignment has discussion enabled.
    if target.assignments.first&.discussion? &&
         user.courses.exists?(id: course.id)
      return true
    end

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
