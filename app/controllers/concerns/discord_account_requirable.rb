# This module expects that the controller has a `course` method that returns
# the course for which Discord account requirement is being enforced.
module DiscordAccountRequirable
  def require_discord_account
    return if current_user.blank?

    return if current_user.discord_account_connected?

    if course.discord_account_required?
      redirect_to edit_user_path(course_requiring_discord: course.id)
    end
  end
end
