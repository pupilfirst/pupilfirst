class TimelineEventFilePolicy < ApplicationPolicy
  def download?
    founders = record.timeline_event.founders

    # Coach can view timeline event files.
    return true if current_user_coaches?(record.timeline_event.target.course, founders)

    # Team members linked directly to the timeline event can access attached files.
    founders.where(id: current_founder).exists?
  end

  def create
    # User must be enrolled as a student.
    return false if current_user.founders.empty?

    # At least one of the student profiles must be non-exited AND non-ended (course AND access).
    current_user.founders.includes(:startup, :course).one? do |founder|
      !(founder.exited? || founder.access_ended? || founder.course.ended?)
    end
  end

  private

  def current_user_coaches?(course, founders)
    return false if current_coach.blank?

    # Current user is a coach if zhe has been linked as reviewer to entire course holding this TEF.
    return true if current_coach.courses.where(id: course).exists?

    startups = Startup.joins(:founders).where(founders: { id: founders })

    # Current user is a coach if zhe has been linked as reviewer directly to any startup that TE founders are currently
    # a part of.
    current_coach.startups.where(id: startups).exists?
  end
end
