# This module expects that the controller has a `course` method that returns
# the course for which Discord account requirement is being enforced.
module DiscordAccountRequirable
  def require_discord_account
    return if current_user.blank?

    return if current_user.discord_account_connected?

    # Redirect only if the user is an active student in the course.
    unless current_user
             .students
             .joins(cohort: :course)
             .where(courses: { id: course.id })
             .merge(Cohort.active)
             .exists?
      return
    end

    if course.discord_account_required?
      redirect_to discord_account_required_user_path(
                    course_requiring_discord: course.id
                  )
    end
  end
end
